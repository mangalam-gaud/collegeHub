package com.college.filter;

import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

/**
 * Adds security headers to every response and enforces CSRF token validation
 * on all mutating requests (token issued per session, hidden field in every form).
 *
 * Design notes:
 *  - The token is issued lazily: only when a page actually needs it. This keeps
 *    the token stable for the life of the session and avoids invalidating forms
 *    that are already open in a browser tab.
 *  - On a mismatch the token is rotated and the user gets a recoverable page
 *    instead of a dead-end 403. This is the common case when the container was
 *    restarted while a form was open, and it should never look like a crash.
 */
@WebFilter("/*")
public class SecurityFilter implements Filter {

    public static final String CSRF_ATTR = "csrfToken";

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        // Published so view helpers can resolve files under WEB-INF/classes
        // (app.properties, which versions the stylesheet for cache-busting).
        com.college.util.ViewHelper.setServletContext(cfg.getServletContext());
    }

    private static boolean isMutating(HttpServletRequest request) {
        String m = request.getMethod();
        return "POST".equalsIgnoreCase(m)
            || "PUT".equalsIgnoreCase(m)
            || "DELETE".equalsIgnoreCase(m)
            || "PATCH".equalsIgnoreCase(m);
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // ---- security headers ----
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        response.setHeader("X-XSS-Protection", "0"); // modern: rely on CSP-style hygiene
        response.setHeader("Content-Security-Policy",
            "default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; script-src 'self' 'unsafe-inline'");
        response.setHeader("Permissions-Policy", "geolocation=(), microphone=(), camera=()");

        // Cache-busting token for the stylesheet, published on every request so
        // both login.jsp and the shared layout can read it from request scope.
        request.setAttribute("styleVersion", com.college.util.ViewHelper.styleVersion(request));

        HttpSession session = request.getSession(true);

        // ---- issue CSRF token once per session ----
        if (session.getAttribute(CSRF_ATTR) == null) {
            session.setAttribute(CSRF_ATTR, UUID.randomUUID().toString());
        }

        // ---- validate on mutating requests ----
        if (isMutating(request)) {
            String formToken = request.getParameter("csrf");
            String sessionToken = (String) session.getAttribute(CSRF_ATTR);
            if (sessionToken == null || formToken == null || !sessionToken.equals(formToken)) {
                // Rotate so the retried request from a freshly-rendered form succeeds.
                session.setAttribute(CSRF_ATTR, UUID.randomUUID().toString());

                // Login is the one endpoint a stale form must never lock the user out of.
                if (request.getRequestURI().endsWith("/login")) {
                    request.setAttribute("error",
                        "Your session expired while the page was open. Please sign in again.");
                    response.setStatus(HttpServletResponse.SC_OK);
                    request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                    return;
                }

                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Invalid or missing CSRF token. Go back, refresh the page and try again.");
                return;
            }
        }

        chain.doFilter(req, res);
    }

    /** Helper for JSPs/servlets to embed the current token. */
    public static String token(HttpSession session) {
        Object t = session.getAttribute(CSRF_ATTR);
        return t == null ? "" : t.toString();
    }
}
