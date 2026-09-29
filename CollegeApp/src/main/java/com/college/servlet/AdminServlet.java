package com.college.servlet;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.college.dao.*;
import com.college.model.*;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final ProgramDAO programDAO = new ProgramDAO();
    private final AcademicDAO academicDAO = new AcademicDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = path(req);
        switch (action) {
            case "users":
                String q = req.getParameter("q");
                req.setAttribute("q", q == null ? "" : q);
                req.setAttribute("students", userDAO.searchByRole("STUDENT", q));
                req.setAttribute("teachers", userDAO.searchByRole("TEACHER", q));
                view(req, resp, "users");
                break;
            case "user-form":
                String editId = req.getParameter("edit");
                if (editId != null) {
                    try { req.setAttribute("editUser", userDAO.getById(Integer.parseInt(editId))); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                req.setAttribute("formRole", req.getParameter("role") != null ? req.getParameter("role") : "STUDENT");
                view(req, resp, "user-form");
                break;
            case "courses":
                req.setAttribute("courses", courseDAO.findAll());
                view(req, resp, "courses");
                break;
            case "course-form":
                String editCourse = req.getParameter("edit");
                if (editCourse != null) {
                    try { req.setAttribute("editCourse", courseDAO.findById(Integer.parseInt(editCourse))); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                req.setAttribute("teachers", userDAO.getByRole("TEACHER"));
                view(req, resp, "course-form");
                break;
            case "notices":
                req.setAttribute("notices", academicDAO.getNotices("ADMIN"));
                view(req, resp, "notices");
                break;
            case "departments":
                req.setAttribute("departments", departmentDAO.getAllDepartments());
                view(req, resp, "departments");
                break;
            case "department-form":
                String editDept = req.getParameter("edit");
                if (editDept != null) {
                    try { req.setAttribute("editDepartment", departmentDAO.getDepartmentById(Integer.parseInt(editDept))); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                req.setAttribute("teachers", userDAO.getByRole("TEACHER"));
                view(req, resp, "department-form");
                break;
            case "programs":
                req.setAttribute("programs", programDAO.getAllPrograms());
                view(req, resp, "programs");
                break;
            case "program-form":
                String editProg = req.getParameter("edit");
                if (editProg != null) {
                    try { req.setAttribute("editProgram", programDAO.getProgramById(Integer.parseInt(editProg))); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                req.setAttribute("departments", departmentDAO.getAllDepartments());
                view(req, resp, "program-form");
                break;
            default:
                req.setAttribute("studentCount", userDAO.countByRole("STUDENT"));
                req.setAttribute("teacherCount", userDAO.countByRole("TEACHER"));
                req.setAttribute("courseCount", courseDAO.countCourses());
                req.setAttribute("notices", academicDAO.getNotices("ADMIN"));
                view(req, resp, "dashboard");
        }
    }

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/admin/" + page + ".jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = path(req);
        switch (action) {
            case "user-save": {
                String idStr = req.getParameter("id");
                String role = req.getParameter("role");
                User u = buildUser(req);
                boolean ok;
                if (idStr != null && !idStr.isBlank()) {
                    try {
                        u.setId(Integer.parseInt(idStr));
                        ok = userDAO.update(u);
                        String pw = req.getParameter("password");
                        if (ok && pw != null && !pw.isBlank()) userDAO.changePassword(u.getId(), pw);
                    } catch (NumberFormatException e) {
                        ok = false;
                    }
                } else {
                    String username = req.getParameter("username");
                    if (username == null || username.isBlank() || userDAO.emailOrUsernameExists(username, u.getEmail())) {
                        req.setAttribute("error", "Username already exists or is invalid.");
                        req.getRequestDispatcher("/WEB-INF/views/admin/user-form.jsp").forward(req, resp);
                        return;
                    }
                    u.setUsername(username);
                    ok = userDAO.create(u, req.getParameter("password"), role);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                break;
            }
            case "user-toggle": {
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    try { userDAO.setActive(Integer.parseInt(idStr), "1".equals(req.getParameter("to"))); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                break;
            }
            case "user-delete": {
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    try { userDAO.delete(Integer.parseInt(idStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                break;
            }
            case "course-save": {
                Course c = new Course();
                String idStr = req.getParameter("id");
                String teacher = req.getParameter("teacherId");
                c.setCode(req.getParameter("code"));
                c.setTitle(req.getParameter("title"));
                c.setCredits(parseInt(req.getParameter("credits"), 3));
                c.setSemester(parseInt(req.getParameter("semester"), 1));
                c.setTeacherId(teacher != null && !teacher.isBlank() ? Integer.parseInt(teacher) : null);
                if (idStr != null && !idStr.isBlank()) {
                    try { c.setId(Integer.parseInt(idStr)); courseDAO.update(c); }
                    catch (NumberFormatException e) { /* ignore */ }
                } else {
                    courseDAO.create(c);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/courses");
                break;
            }
            case "course-delete": {
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    try { courseDAO.delete(Integer.parseInt(idStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/courses");
                break;
            }
            case "notice-post": {
                User me = (User) req.getSession().getAttribute("user");
                Notice n = new Notice();
                n.setTitle(req.getParameter("title"));
                n.setBody(req.getParameter("body"));
                n.setAudience(req.getParameter("audience") != null ? req.getParameter("audience") : "ALL");
                academicDAO.createNotice(n, me.getId());
                resp.sendRedirect(req.getContextPath() + "/admin/notices");
                break;
            }
            case "notice-delete": {
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    try { academicDAO.deleteNotice(Integer.parseInt(idStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/notices");
                break;
            }
            case "department-save": {
                Department d = new Department();
                String idStr = req.getParameter("id");
                d.setName(req.getParameter("name"));
                d.setCode(req.getParameter("code"));
                String hod = req.getParameter("hodId");
                d.setHodId(hod != null && !hod.isBlank() ? Integer.parseInt(hod) : 0);
                d.setDescription(req.getParameter("description"));
                if (idStr != null && !idStr.isBlank()) {
                    try { d.setId(Integer.parseInt(idStr)); departmentDAO.updateDepartment(d); }
                    catch (NumberFormatException e) { /* ignore */ }
                } else {
                    departmentDAO.createDepartment(d);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/departments");
                break;
            }
            case "program-save": {
                Program p = new Program();
                String idStr = req.getParameter("id");
                p.setCode(req.getParameter("code"));
                p.setName(req.getParameter("name"));
                String deptStr = req.getParameter("departmentId");
                if (deptStr != null && !deptStr.isBlank()) {
                    try { p.setDepartmentId(Integer.parseInt(deptStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                String durStr = req.getParameter("durationYears");
                p.setDurationYears(parseInt(durStr, 4));
                String semStr = req.getParameter("totalSemesters");
                p.setTotalSemesters(parseInt(semStr, 8));
                p.setEligibilityCriteria(req.getParameter("eligibilityCriteria"));
                if (idStr != null && !idStr.isBlank()) {
                    try { p.setId(Integer.parseInt(idStr)); }
                    catch (NumberFormatException e) { /* ignore */ }
                }
                programDAO.createProgram(p);
                resp.sendRedirect(req.getContextPath() + "/admin/programs");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    private User buildUser(HttpServletRequest req) {
        User u = new User();
        u.setFullName(req.getParameter("fullName"));
        u.setEmail(req.getParameter("email"));
        u.setPhone(req.getParameter("phone"));
        u.setGender(req.getParameter("gender"));
        u.setDob(req.getParameter("dob"));
        u.setAddress(req.getParameter("address"));
        return u;
    }

    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s) : def; } catch (Exception e) { return def; }
    }
}