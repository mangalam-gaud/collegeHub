package com.college.servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import com.college.dao.*;
import com.college.model.*;

@WebServlet("/teacher/*")
public class TeacherServlet extends HttpServlet {
    private final CourseDAO courseDAO = new CourseDAO();
    private final AcademicDAO academicDAO = new AcademicDAO();

    /**
     * Resolves the course for attendance/marks screens.
     *
     * These pages are linked directly from the sidebar, so {@code courseId} is
     * routinely absent. Falling back to the teacher's first assigned course keeps
     * the page useful instead of throwing NumberFormatException; when the teacher
     * has no courses at all we send them to the course list to pick one.
     *
     * @return the course to render, or null when the request has been answered
     */
    private Course resolveCourse(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        String raw = req.getParameter("courseId");
        if (raw != null && !raw.trim().isEmpty()) {
            try {
                Course c = courseDAO.findById(Integer.parseInt(raw.trim()));
                if (c != null) return c;
            } catch (NumberFormatException ignored) {
                // fall through to the default-course path
            }
        }
        List<Course> mine = courseDAO.findByTeacher(user.getId());
        if (mine != null && !mine.isEmpty()) return mine.get(0);
        resp.sendRedirect(req.getContextPath() + "/teacher/courses");
        return null;
    }

    /** CSV export of attendance or marks for one of the teacher's courses. */
    private void exportCsv(HttpServletRequest req, HttpServletResponse resp, User user, boolean attendance)
            throws IOException {
        try {
            String raw = req.getParameter("courseId");
            if (raw == null || raw.trim().isEmpty()) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "courseId is required");
                return;
            }
            Course c = courseDAO.findById(Integer.parseInt(raw.trim()));
            // authorization: only the assigned teacher (or admin) may export
            if (c == null || (!"ADMIN".equals(user.getRole()) &&
                    (c.getTeacherId() == null || c.getTeacherId() != user.getId()))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            final int courseId = c.getId();
            resp.setContentType("text/csv;charset=UTF-8");
            resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + c.getCode() + "-" + (attendance ? "attendance" : "marks") + ".csv\"");
            var w = resp.getWriter();
            w.println("Course," + c.getCode() + " - " + c.getTitle());
            if (attendance) {
                w.println("Student,Username,Attended,Total,Percent");
                for (Map<String, String> s : academicDAO.getEnrolledStudents(courseId)) {
                    // per-student attendance for this course
                    int[] at = attendanceFor(Integer.parseInt(s.get("id")), courseId);
                    double pct = at[1] == 0 ? 0 : Math.round(at[0] * 1000.0 / at[1]) / 10.0;
                    w.println(csv(s.get("name")) + "," + csv(s.get("username")) + "," + at[0] + "," + at[1] + "," + pct);
                }
            } else {
                w.println("Student,Username,Exam,Marks,Max,Percent");
                for (Map<String, Object> m : academicDAO.getCourseMarks(courseId)) {
                    double pct = (Double) m.get("max") == 0 ? 0
                        : Math.round((Double) m.get("marks") * 1000.0 / (Double) m.get("max")) / 10.0;
                    w.println(csv((String) m.get("name")) + "," + csv((String) m.get("username")) + ","
                        + m.get("examType") + "," + m.get("marks") + "," + m.get("max") + "," + pct);
                }
            }
            w.flush();
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private int[] attendanceFor(int studentId, int courseId) {
        int[] out = new int[2];
        String sql = "SELECT SUM(status='PRESENT') a, COUNT(*) t FROM attendance WHERE student_id=? AND course_id=?";
        try (java.sql.Connection cn = com.college.util.DBUtil.getConnection();
             java.sql.PreparedStatement p = cn.prepareStatement(sql)) {
            p.setInt(1, studentId); p.setInt(2, courseId);
            try (java.sql.ResultSet r = p.executeQuery()) {
                if (r.next()) { out[0] = r.getInt(1); out[1] = r.getInt(2); }
            }
        } catch (java.sql.SQLException e) { e.printStackTrace(); }
        return out;
    }

    private String csv(String v) {
        if (v == null) return "";
        if (v.contains(",") || v.contains("\"") || v.contains("\n"))
            return "\"" + v.replace("\"", "\"\"") + "\"";
        return v;
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/teacher/" + page + ".jsp").forward(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "export-attendance":
                exportCsv(req, resp, user, true);
                break;
            case "export-marks":
                exportCsv(req, resp, user, false);
                break;
            case "courses":
                req.setAttribute("courses", courseDAO.findByTeacher(user.getId()));
                view(req, resp, "courses");
                break;
            case "attendance": {
                Course c = resolveCourse(req, resp, user);
                if (c == null) return;
                req.setAttribute("course", c);
                req.setAttribute("students", academicDAO.getEnrolledStudents(c.getId()));
                view(req, resp, "attendance");
                break;
            }
            case "marks": {
                Course c = resolveCourse(req, resp, user);
                if (c == null) return;
                req.setAttribute("course", c);
                req.setAttribute("students", academicDAO.getEnrolledStudents(c.getId()));
                req.setAttribute("existingMarks", academicDAO.getCourseMarks(c.getId()));
                view(req, resp, "marks");
                break;
            }
            case "notices":
                req.setAttribute("notices", academicDAO.getNotices("TEACHER"));
                view(req, resp, "notices");
                break;
            default:
                req.setAttribute("courses", courseDAO.findByTeacher(user.getId()));
                req.setAttribute("notices", academicDAO.getNotices("TEACHER"));
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "attendance-save": {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                String date = req.getParameter("date");
                for (String sid : req.getParameterValues("studentIds")) {
                    String status = "PRESENT".equals(req.getParameter("status_" + sid)) ? "PRESENT" : "ABSENT";
                    academicDAO.markAttendance(Integer.parseInt(sid), courseId, date, status, user.getId());
                }
                resp.sendRedirect(req.getContextPath() + "/teacher/attendance?courseId=" + courseId + "&saved=1");
                break;
            }
            case "marks-save": {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                String examType = req.getParameter("examType");
                double max = Double.parseDouble(req.getParameter("maxMarks"));
                for (String sid : req.getParameterValues("studentIds")) {
                    String m = req.getParameter("marks_" + sid);
                    if (m != null && !m.isBlank()) {
                        academicDAO.saveMark(Integer.parseInt(sid), courseId, examType,
                                Double.parseDouble(m), max, user.getId());
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/teacher/marks?courseId=" + courseId + "&saved=1");
                break;
            }
            case "notice-post": {
                Notice n = new Notice();
                n.setTitle(req.getParameter("title"));
                n.setBody(req.getParameter("body"));
                n.setAudience("STUDENT".equals(req.getParameter("audience")) ? "STUDENT" : "ALL");
                academicDAO.createNotice(n, user.getId());
                resp.sendRedirect(req.getContextPath() + "/teacher/notices");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/teacher/dashboard");
        }
    }
}
