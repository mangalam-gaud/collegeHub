package com.college.servlet;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.college.dao.*;
import com.college.model.*;

@WebServlet("/student/*")
public class StudentServlet extends HttpServlet {
    private final CourseDAO courseDAO = new CourseDAO();
    private final AcademicDAO academicDAO = new AcademicDAO();
    private final UserDAO userDAO = new UserDAO();
    private final FeeDAO feeDAO = new FeeDAO();

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/student/" + page + ".jsp").forward(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "courses":
                req.setAttribute("enrolled", courseDAO.findByStudent(user.getId()));
                req.setAttribute("available", courseDAO.findNotEnrolledByStudent(user.getId()));
                view(req, resp, "courses");
                break;
            case "attendance":
                req.setAttribute("summary", academicDAO.getAttendanceSummary(user.getId()));
                view(req, resp, "attendance");
                break;
            case "marks":
                req.setAttribute("marks", academicDAO.getMarks(user.getId()));
                view(req, resp, "marks");
                break;
            case "notices":
                req.setAttribute("notices", academicDAO.getNotices("STUDENT"));
                view(req, resp, "notices");
                break;
            case "profile":
                req.setAttribute("profile", userDAO.getById(user.getId()));
                view(req, resp, "profile");
                break;
            case "my-fees":
                FeeStructure fs = feeDAO.getApplicableFeeStructure(user.getId());
                java.util.List<FeePayment> payments = feeDAO.getFeePaymentsByStudent(user.getId());
                req.setAttribute("feeStructure", fs);
                req.setAttribute("payments", payments);
                if (fs != null) {
                    double totalPaid = payments.stream()
                            .filter(p -> "COMPLETED".equals(p.getStatus()))
                            .mapToDouble(FeePayment::getAmountPaid).sum();
                    req.setAttribute("totalPaid", totalPaid);
                    req.setAttribute("balance", fs.getTotalFee() - totalPaid);
                }
                view(req, resp, "my-fees");
                break;
            default:
                req.setAttribute("enrolled", courseDAO.findByStudent(user.getId()));
                req.setAttribute("attendance", academicDAO.getAttendanceSummary(user.getId()));
                req.setAttribute("marks", academicDAO.getMarks(user.getId()));
                req.setAttribute("notices", academicDAO.getNotices("STUDENT"));
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "enroll": {
                String courseIdStr = req.getParameter("courseId");
                if (courseIdStr != null && !courseIdStr.isBlank()) {
                    try { courseDAO.enroll(user.getId(), Integer.parseInt(courseIdStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                resp.sendRedirect(req.getContextPath() + "/student/courses");
                break;
            }
            case "unenroll": {
                String courseIdStr = req.getParameter("courseId");
                if (courseIdStr != null && !courseIdStr.isBlank()) {
                    try { courseDAO.unenroll(user.getId(), Integer.parseInt(courseIdStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                resp.sendRedirect(req.getContextPath() + "/student/courses");
                break;
            }
            case "profile-save": {
                User u = new User();
                u.setId(user.getId());
                u.setFullName(req.getParameter("fullName"));
                u.setEmail(req.getParameter("email"));
                u.setPhone(req.getParameter("phone"));
                u.setGender(req.getParameter("gender"));
                u.setDob(req.getParameter("dob"));
                u.setAddress(req.getParameter("address"));
                userDAO.update(u);
                req.getSession().setAttribute("user", userDAO.getById(user.getId()));
                resp.sendRedirect(req.getContextPath() + "/student/profile?saved=1");
                break;
            }
            case "password-save": {
                String pw = req.getParameter("password");
                if (pw != null && pw.length() >= 6) {
                    userDAO.changePassword(user.getId(), pw);
                    resp.sendRedirect(req.getContextPath() + "/student/profile?pwchanged=1");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/student/profile?pwerror=1");
                }
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }
}