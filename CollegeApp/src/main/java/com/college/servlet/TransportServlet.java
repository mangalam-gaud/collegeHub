package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/transport/*")
public class TransportServlet extends HttpServlet {
    private final TransportDAO transportDAO = new TransportDAO();
    private final UserDAO userDAO = new UserDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/transport/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "routes":
                req.setAttribute("routes", transportDAO.getAllRoutes());
                view(req, resp, "routes");
                break;
            case "route-stops":
                String routeId = req.getParameter("routeId");
                if (routeId != null) {
                    req.setAttribute("stops", transportDAO.getStopsByRoute(Integer.parseInt(routeId)));
                    req.setAttribute("routeId", routeId);
                }
                view(req, resp, "route-stops");
                break;
            case "bookings":
                req.setAttribute("bookings", transportDAO.getStudentBookings(user.getId()));
                view(req, resp, "bookings");
                break;
            case "book-route":
                req.setAttribute("routes", transportDAO.getAllRoutes());
                view(req, resp, "book-route");
                break;
            default:
                req.setAttribute("routes", transportDAO.getAllRoutes());
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "book-route": {
                int routeId = Integer.parseInt(req.getParameter("routeId"));
                int stopId = Integer.parseInt(req.getParameter("stopId"));
                transportDAO.bookRoute(user.getId(), routeId, stopId, 1);
                resp.sendRedirect(req.getContextPath() + "/transport/bookings?booked=1");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/transport/dashboard");
        }
    }
}