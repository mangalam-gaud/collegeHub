package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/events/*")
public class EventServlet extends HttpServlet {
    private final EventDAO eventDAO = new EventDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "list" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/events/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "list":
                String type = req.getParameter("type");
                req.setAttribute("events", eventDAO.getPublishedEvents(type, 0, 20));
                req.setAttribute("type", type == null ? "" : type);
                view(req, resp, "list");
                break;
            case "manage":
                req.setAttribute("events", eventDAO.getAllEvents(null, 0, 50));
                view(req, resp, "manage");
                break;
            case "event-form":
                String editId = req.getParameter("edit");
                if (editId != null) req.setAttribute("editEvent", eventDAO.getEventById(Integer.parseInt(editId)));
                view(req, resp, "event-form");
                break;
            case "detail":
                String id = req.getParameter("id");
                if (id != null) req.setAttribute("event", eventDAO.getEventById(Integer.parseInt(id)));
                view(req, resp, "detail");
                break;
            default:
                req.setAttribute("events", eventDAO.getPublishedEvents(null, 0, 10));
                req.setAttribute("upcoming", eventDAO.getUpcomingEventsForUser(user.getId(), user.getRole()));
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "event-save": {
                Event event = new Event();
                String idStr = req.getParameter("id");
                event.setTitle(req.getParameter("title"));
                event.setDescription(req.getParameter("description"));
                event.setEventType(req.getParameter("eventType"));
                event.setStartDatetime(req.getParameter("startDatetime"));
                event.setEndDatetime(req.getParameter("endDatetime"));
                event.setLocation(req.getParameter("location"));
                event.setOrganizerId(user.getId());
                event.setTargetAudience(req.getParameter("targetAudience"));
                event.setMaxParticipants(parseInt(req.getParameter("maxParticipants"), 0));
                event.setRegistrationRequired("on".equals(req.getParameter("registrationRequired")));
                event.setRegistrationDeadline(req.getParameter("registrationDeadline"));
                event.setPublished("on".equals(req.getParameter("isPublished")));
                if (idStr != null && !idStr.isBlank()) event.setId(Integer.parseInt(idStr));
                eventDAO.createEvent(event);
                resp.sendRedirect(req.getContextPath() + "/events/manage");
                break;
            }
            case "register": {
                int eventId = Integer.parseInt(req.getParameter("eventId"));
                eventDAO.registerForEvent(eventId, user.getId());
                resp.sendRedirect(req.getContextPath() + "/events/detail?id=" + eventId + "&registered=1");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/events/list");
        }
    }

    private int parseInt(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}