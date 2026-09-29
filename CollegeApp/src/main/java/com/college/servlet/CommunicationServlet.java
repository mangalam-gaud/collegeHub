package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/messages/*")
public class CommunicationServlet extends HttpServlet {
    private final CommunicationDAO commDAO = new CommunicationDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "inbox" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/communication/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "inbox":
                req.setAttribute("messages", commDAO.getInbox(user.getId(), 0, 20));
                req.setAttribute("unreadCount", commDAO.getUnreadCount(user.getId()));
                view(req, resp, "inbox");
                break;
            case "sent":
                req.setAttribute("messages", commDAO.getSentMessages(user.getId(), 0, 20));
                view(req, resp, "sent");
                break;
            case "compose":
                view(req, resp, "compose");
                break;
            case "notifications":
                req.setAttribute("notifications", commDAO.getNotifications(user.getId(), 0, 20));
                req.setAttribute("unreadNotifCount", commDAO.getUnreadNotificationCount(user.getId()));
                view(req, resp, "notifications");
                break;
            default:
                req.setAttribute("messages", commDAO.getInbox(user.getId(), 0, 10));
                req.setAttribute("unreadCount", commDAO.getUnreadCount(user.getId()));
                req.setAttribute("notifications", commDAO.getNotifications(user.getId(), 0, 5));
                req.setAttribute("unreadNotifCount", commDAO.getUnreadNotificationCount(user.getId()));
                view(req, resp, "inbox");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "send": {
                Message msg = new Message();
                msg.setSenderId(user.getId());
                msg.setRecipientId(Integer.parseInt(req.getParameter("recipientId")));
                msg.setSubject(req.getParameter("subject"));
                msg.setBody(req.getParameter("body"));
                msg.setMessageType(req.getParameter("messageType"));
                msg.setPriority(req.getParameter("priority"));
                commDAO.sendMessage(msg);
                resp.sendRedirect(req.getContextPath() + "/messages/sent?sent=1");
                break;
            }
            case "mark-notification-read": {
                int notifId = Integer.parseInt(req.getParameter("notificationId"));
                commDAO.markNotificationRead(notifId, user.getId());
                resp.sendRedirect(req.getContextPath() + "/messages/notifications");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/messages/inbox");
        }
    }
}