package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/grievance/*")
public class GrievanceServlet extends HttpServlet {
    private final GrievanceDAO grievanceDAO = new GrievanceDAO();
    private final UserDAO userDAO = new UserDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/grievance/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "my-grievances":
                req.setAttribute("grievances", grievanceDAO.getGrievancesByStudent(user.getId()));
                view(req, resp, "my-grievances");
                break;
            case "all":
                String status = req.getParameter("status");
                String category = req.getParameter("category");
                req.setAttribute("grievances", grievanceDAO.getAllGrievances(status, category, 0, 50));
                req.setAttribute("status", status == null ? "" : status);
                req.setAttribute("category", category == null ? "" : category);
                view(req, resp, "all");
                break;
            case "detail":
                String id = req.getParameter("id");
                if (id != null) req.setAttribute("grievance", grievanceDAO.getGrievanceById(Integer.parseInt(id)));
                view(req, resp, "detail");
                break;
            case "new":
                view(req, resp, "new");
                break;
            default:
                req.setAttribute("myGrievances", grievanceDAO.getGrievancesByStudent(user.getId()));
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "submit": {
                Grievance g = new Grievance();
                g.setStudentId(user.getId());
                g.setCategory(req.getParameter("category"));
                g.setSubject(req.getParameter("subject"));
                g.setDescription(req.getParameter("description"));
                g.setPriority(req.getParameter("priority"));
                g.setAnonymous("on".equals(req.getParameter("isAnonymous")));
                grievanceDAO.submitGrievance(g);
                resp.sendRedirect(req.getContextPath() + "/grievance/my-grievances?submitted=1");
                break;
            }
            case "update": {
                Grievance g = new Grievance();
                g.setId(Integer.parseInt(req.getParameter("id")));
                g.setCategory(req.getParameter("category"));
                g.setSubject(req.getParameter("subject"));
                g.setDescription(req.getParameter("description"));
                g.setPriority(req.getParameter("priority"));
                g.setStatus(req.getParameter("status"));
                g.setAssignedTo(req.getParameter("assignedTo") != null ? Integer.parseInt(req.getParameter("assignedTo")) : 0);
                g.setResolution(req.getParameter("resolution"));
                g.setResolvedAt(req.getParameter("resolvedAt"));
                g.setSatisfactionRating(parseInt(req.getParameter("satisfactionRating"), 0));
                g.setFeedbackText(req.getParameter("feedbackText"));
                grievanceDAO.updateGrievance(g);
                resp.sendRedirect(req.getContextPath() + "/grievance/all?updated=1");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/grievance/dashboard");
        }
    }

    private int parseInt(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}