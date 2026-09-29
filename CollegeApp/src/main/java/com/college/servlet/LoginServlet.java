package com.college.servlet;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.college.dao.UserDAO;
import com.college.model.User;
import com.college.util.LoginRateLimiter;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    /**
     * Where each role lands after signing in. Roles that do not own a dedicated
     * dashboard servlet are pointed at the module they actually manage.
     */
    public static String landingPageFor(String role) {
        if (role == null) return "login";
        switch (role) {
            case "ADMIN":            return "admin/dashboard";
            case "TEACHER":          return "teacher/dashboard";
            case "STUDENT":          return "student/dashboard";
            case "ACCOUNTANT":       return "fee/dashboard";
            case "LIBRARIAN":        return "library/dashboard";
            case "HOSTEL_WARDEN":    return "hostel/dashboard";
            case "TRANSPORT_MANAGER":return "transport/dashboard";
            case "PARENT":           return "student/dashboard";
            default:                 return "admin/dashboard";
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession existing = req.getSession(false);
        if (existing != null && existing.getAttribute("user") != null) {
            redirectHome((User) existing.getAttribute("user"), req, resp);
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        username = (username == null) ? "" : username.trim();

        // rate limit: 5 failed attempts / 10 min per username
        if (LoginRateLimiter.isBlocked(username)) {
            req.setAttribute("error", "Too many failed attempts. Try again in a few minutes.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        User user = username.isEmpty() ? null : userDAO.authenticate(username, password == null ? "" : password);

        if (user == null) {
            LoginRateLimiter.recordFailure(username);
            int left = LoginRateLimiter.remaining(username);
            req.setAttribute("error", "Invalid username or password." +
                (left <= 2 ? " (" + left + " attempt" + (left == 1 ? "" : "s") + " left)" : ""));
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        LoginRateLimiter.reset(username);

        // Session fixation protection: rotate the session ID in place rather than
        // invalidating the session. This keeps the CSRF token and any in-flight
        // form state intact while still changing the identifier the attacker
        // might have pre-seeded.
        HttpSession session = req.getSession(true);
        if (req.getRequestedSessionId() != null) {
            try {
                req.changeSessionId();
            } catch (IllegalStateException ignored) {
                // No prior session id to rotate - nothing to do.
            }
        }
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(30 * 60);

        // Honour a deep link the user was trying to reach before being bounced here.
        Object target = session.getAttribute("postLoginTarget");
        session.removeAttribute("postLoginTarget");
        if (target != null) {
            String t = target.toString();
            if (t.startsWith(req.getContextPath() + "/")
                && com.college.filter.AuthFilter.isPermitted(t, user.getRole())) {
                resp.sendRedirect(t);
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/" + landingPageFor(user.getRole()));
    }

    private void redirectHome(User user, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/" + landingPageFor(user.getRole()));
    }
}
