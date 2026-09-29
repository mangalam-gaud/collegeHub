package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/leave/*")
public class LeaveServlet extends HttpServlet {
    private final LeaveDAO leaveDAO = new LeaveDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/leave/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "types":
                req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
                view(req, resp, "leave-types");
                break;
            case "my-requests":
                req.setAttribute("requests", leaveDAO.getLeaveRequestsByUser(user.getId()));
                view(req, resp, "my-requests");
                break;
            case "pending":
                req.setAttribute("requests", leaveDAO.getPendingLeaveRequests(user.getId()));
                view(req, resp, "pending");
                break;
            case "all-requests":
                String status = req.getParameter("status");
                req.setAttribute("requests", leaveDAO.getAllLeaveRequests(status, 0, 50));
                req.setAttribute("status", status == null ? "" : status);
                view(req, resp, "all-requests");
                break;
            case "new-request":
                req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
                view(req, resp, "leave-form");
                break;
            default:
                req.setAttribute("leaveTypes", leaveDAO.getAllLeaveTypes());
                req.setAttribute("myRequests", leaveDAO.getLeaveRequestsByUser(user.getId()));
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "submit-request": {
                LeaveRequest lr = new LeaveRequest();
                lr.setUserId(user.getId());
                lr.setLeaveTypeId(Integer.parseInt(req.getParameter("leaveTypeId")));
                lr.setStartDate(req.getParameter("startDate"));
                lr.setEndDate(req.getParameter("endDate"));
                lr.setTotalDays(Double.parseDouble(req.getParameter("totalDays")));
                lr.setReason(req.getParameter("reason"));
                lr.setContactDuringLeave(req.getParameter("contactDuringLeave"));
                leaveDAO.submitLeaveRequest(lr);
                resp.sendRedirect(req.getContextPath() + "/leave/my-requests?submitted=1");
                break;
            }
            case "review-request": {
                int requestId = Integer.parseInt(req.getParameter("requestId"));
                String status = req.getParameter("status");
                String remarks = req.getParameter("remarks");
                leaveDAO.reviewLeaveRequest(requestId, user.getId(), status, remarks);
                resp.sendRedirect(req.getContextPath() + "/leave/pending?reviewed=1");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/leave/dashboard");
        }
    }
}