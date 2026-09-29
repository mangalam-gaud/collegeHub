package com.college.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import com.college.model.User;
import com.college.servlet.LoginServlet;

/**
 * RBAC filter. web.xml maps it to all protected paths.
 * Requires a logged-in session and that the caller's role is permitted for the
 * requested path.
 *
 * A single "required role per path" model is wrong for this application: most
 * modules are shared between the department that manages them and the students
 * who consume them (a student reads /fee/my-fees, a librarian writes /fee/*).
 * Each path therefore declares the full set of roles allowed to enter it, and
 * ADMIN is always permitted.
 */
public class AuthFilter implements Filter {

    private static final Map<String, Set<String>> ALLOWED = new HashMap<>();

    /** Every role the application recognises. */
    private static final Set<String> ALL_ROLES = set(
        "ADMIN", "TEACHER", "STUDENT", "PARENT", "LIBRARIAN",
        "ACCOUNTANT", "HOSTEL_WARDEN", "TRANSPORT_MANAGER");

    static {
        // prefix -> roles allowed
        ALLOWED.put("/admin/",     set("ADMIN"));
        ALLOWED.put("/teacher/",   set("ADMIN", "TEACHER"));
        ALLOWED.put("/student/",   set("ADMIN", "TEACHER", "STUDENT", "PARENT"));

        // Academic is managed by teachers, but every student reads their own results.
        ALLOWED.put("/academic/",  set("ADMIN", "TEACHER", "STUDENT"));

        // Fees: accountants manage, students pay/view their own.
        ALLOWED.put("/fee/",       set("ADMIN", "ACCOUNTANT", "STUDENT"));

        // Library: librarians manage the catalogue, students borrow.
        ALLOWED.put("/library/",   set("ADMIN", "LIBRARIAN", "STUDENT", "TEACHER"));

        // Hostel: wardens manage, residents view their allocation.
        ALLOWED.put("/hostel/",    set("ADMIN", "HOSTEL_WARDEN", "STUDENT"));

        // Transport: managers manage routes, students book seats.
        ALLOWED.put("/transport/", set("ADMIN", "TRANSPORT_MANAGER", "STUDENT"));

        // Leave: any employee (teaching or support staff) or student may apply;
        // teachers and admins additionally review. The nav offers a Leave link
        // to every role, so every role must be able to reach this module.
        ALLOWED.put("/leave/", ALL_ROLES);

        // Shared, open to every signed-in user.
        ALLOWED.put("/messages/", ALL_ROLES);
        ALLOWED.put("/events/",   ALL_ROLES);
        ALLOWED.put("/grievance/", set("ADMIN", "TEACHER", "STUDENT"));
    }

    private static Set<String> set(String... roles) {
        return new HashSet<>(Arrays.asList(roles));
    }

    @Override
    public void init(FilterConfig cfg) throws ServletException {
        // Published so view helpers can resolve files under WEB-INF/classes
        // (app.properties, which versions the stylesheet for cache-busting).
        com.college.util.ViewHelper.setServletContext(cfg.getServletContext());
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp_rememberTarget(request, response);
            return;
        }

        if (!isPermitted(request.getRequestURI(), user.getRole())) {
            // Send them to their own landing page rather than a dead end.
            response.sendRedirect(request.getContextPath() + "/"
                + LoginServlet.landingPageFor(user.getRole()));
            return;
        }

        chain.doFilter(req, res);
    }

    private void resp_rememberTarget(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String target = request.getRequestURI() + (request.getQueryString() != null
            ? "?" + request.getQueryString() : "");
        // Only same-app, single-hop paths are safe to bounce back to.
        if (target.startsWith(request.getContextPath() + "/")
            && target.indexOf("//", request.getContextPath().length()) < 0) {
            HttpSession s = request.getSession(true);
            s.setAttribute("postLoginTarget", target);
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }

    public static boolean isPermitted(String uri, String role) {
        if (role == null) return false;
        if ("ADMIN".equals(role)) return true;
        for (Map.Entry<String, Set<String>> e : ALLOWED.entrySet()) {
            if (uri.contains(e.getKey())) {
                return e.getValue().contains(role);
            }
        }
        // Unmapped protected path: any authenticated user may enter.
        return true;
    }
}
