package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import com.college.util.DBUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/academic/*")
public class AcademicServlet extends HttpServlet {
    private final AcademicDAO academicDAO = new AcademicDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final UserDAO userDAO = new UserDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/academic/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "academic-years":
                req.setAttribute("academicYears", academicDAO.getAllAcademicYears());
                view(req, resp, "academic-years");
                break;
            case "academic-year-form":
                String ayEdit = req.getParameter("edit");
                if (ayEdit != null) req.setAttribute("editAcademicYear", academicDAO.getAcademicYearById(Integer.parseInt(ayEdit)));
                view(req, resp, "academic-year-form");
                break;
            case "semesters": {
                // Accept either parameter name: the sidebar and the academic-years
                // list link with "ayId", the semester form with "academicYearId".
                String ayId = req.getParameter("ayId");
                if (ayId == null || ayId.trim().isEmpty()) {
                    ayId = req.getParameter("academicYearId");
                }
                List<AcademicYear> allYears = academicDAO.getAllAcademicYears();
                if (ayId == null || ayId.trim().isEmpty()) {
                    // Default to the current academic year so the page is never empty
                    // when reached from the sidebar.
                    AcademicYear current = null;
                    for (AcademicYear y : allYears) {
                        if (y.isCurrent()) { current = y; break; }
                    }
                    if (current == null && !allYears.isEmpty()) current = allYears.get(0);
                    if (current != null) ayId = String.valueOf(current.getId());
                }
                List<Semester> sems = new ArrayList<>();
                if (ayId != null) {
                    try {
                        sems = academicDAO.getSemestersByAcademicYear(Integer.parseInt(ayId.trim()));
                    } catch (NumberFormatException ignored) {
                        sems = new ArrayList<>();
                    }
                }
                req.setAttribute("semesters", sems);
                req.setAttribute("academicYearId", ayId == null ? "" : ayId);
                req.setAttribute("academicYears", allYears);
                view(req, resp, "semesters");
                break;
            }
            case "semester-form":
                String semEdit = req.getParameter("edit");
                if (semEdit != null) req.setAttribute("editSemester", academicDAO.getSemesterById(Integer.parseInt(semEdit)));
                req.setAttribute("academicYears", academicDAO.getAllAcademicYears());
                view(req, resp, "semester-form");
                break;
            case "timetable-slots":
                req.setAttribute("slots", academicDAO.getAllTimetableSlots());
                view(req, resp, "timetable-slots");
                break;
            case "timetable":
                String semId = req.getParameter("semesterId");
                if (semId != null) {
                    req.setAttribute("timetable", academicDAO.getTimetableBySemester(Integer.parseInt(semId)));
                    req.setAttribute("semester", academicDAO.getSemesterById(Integer.parseInt(semId)));
                }
                view(req, resp, "timetable");
                break;
            case "timetable-form":
                String ttEdit = req.getParameter("edit");
                if (ttEdit != null) {
                    var list = academicDAO.getTimetableBySemester(Integer.parseInt(ttEdit));
                    if (!list.isEmpty()) req.setAttribute("editTimetable", list.get(0));
                }
                req.setAttribute("courses", courseDAO.findAll());
                req.setAttribute("slots", academicDAO.getAllTimetableSlots());
                req.setAttribute("semesters", academicDAO.getAllAcademicYears().stream().flatMap(ay -> academicDAO.getSemestersByAcademicYear(ay.getId()).stream()).toList());
                view(req, resp, "timetable-form");
                break;
            case "exams":
                String examSem = req.getParameter("semesterId");
                if (examSem != null) req.setAttribute("exams", academicDAO.getExamsBySemester(Integer.parseInt(examSem)));
                view(req, resp, "exams");
                break;
            case "exam-form":
                String exEdit = req.getParameter("edit");
                if (exEdit != null) req.setAttribute("editExam", academicDAO.getExamById(Integer.parseInt(exEdit)));
                req.setAttribute("courses", courseDAO.findAll());
                req.setAttribute("semesters", academicDAO.getAllAcademicYears().stream().flatMap(ay -> academicDAO.getSemestersByAcademicYear(ay.getId()).stream()).toList());
                view(req, resp, "exam-form");
                break;
            case "exam-results":
                String examId = req.getParameter("examId");
                if (examId != null) {
                    req.setAttribute("results", academicDAO.getExamResults(Integer.parseInt(examId)));
                    req.setAttribute("exam", academicDAO.getExamById(Integer.parseInt(examId)));
                }
                view(req, resp, "exam-results");
                break;
            default:
                AcademicYear current = academicDAO.getCurrentAcademicYear();
                Semester currentSem = academicDAO.getCurrentSemester();
                req.setAttribute("currentAcademicYear", current);
                req.setAttribute("currentSemester", currentSem);
                req.setAttribute("academicYears", academicDAO.getAllAcademicYears());
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "academic-year-save": {
                AcademicYear ay = new AcademicYear();
                String idStr = req.getParameter("id");
                ay.setName(req.getParameter("name"));
                ay.setStartDate(req.getParameter("startDate"));
                ay.setEndDate(req.getParameter("endDate"));
                ay.setCurrent("on".equals(req.getParameter("isCurrent")));
                ay.setActive("on".equals(req.getParameter("isActive")));
                if (idStr != null && !idStr.isBlank()) {
                    ay.setId(Integer.parseInt(idStr));
                }
                academicDAO.createAcademicYear(ay);
                resp.sendRedirect(req.getContextPath() + "/academic/academic-years");
                break;
            }
            case "semester-save": {
                Semester s = new Semester();
                String idStr = req.getParameter("id");
                s.setAcademicYearId(Integer.parseInt(req.getParameter("academicYearId")));
                s.setName(req.getParameter("name"));
                s.setNumber(Integer.parseInt(req.getParameter("number")));
                s.setStartDate(req.getParameter("startDate"));
                s.setEndDate(req.getParameter("endDate"));
                s.setRegistrationStart(req.getParameter("registrationStart"));
                s.setRegistrationEnd(req.getParameter("registrationEnd"));
                s.setExamStart(req.getParameter("examStart"));
                s.setExamEnd(req.getParameter("examEnd"));
                s.setBreakStart(req.getParameter("breakStart"));
                s.setBreakEnd(req.getParameter("breakEnd"));
                s.setCurrent("on".equals(req.getParameter("isCurrent")));
                s.setActive("on".equals(req.getParameter("isActive")));
                if (idStr != null && !idStr.isBlank()) s.setId(Integer.parseInt(idStr));
                academicDAO.createSemester(s);
                resp.sendRedirect(req.getContextPath() + "/academic/semesters?academicYearId=" + s.getAcademicYearId());
                break;
            }
            case "timetable-save": {
                Timetable t = new Timetable();
                String idStr = req.getParameter("id");
                t.setCourseId(Integer.parseInt(req.getParameter("courseId")));
                t.setSemesterId(Integer.parseInt(req.getParameter("semesterId")));
                t.setSlotId(Integer.parseInt(req.getParameter("slotId")));
                t.setRoom(req.getParameter("room"));
                t.setBuilding(req.getParameter("building"));
                t.setEffectiveFrom(req.getParameter("effectiveFrom"));
                t.setEffectiveTo(req.getParameter("effectiveTo"));
                t.setRecurring("on".equals(req.getParameter("isRecurring")));
                t.setCreatedBy(user.getId());
                if (idStr != null && !idStr.isBlank()) t.setId(Integer.parseInt(idStr));
                academicDAO.createTimetableEntry(t);
                resp.sendRedirect(req.getContextPath() + "/academic/timetable?semesterId=" + t.getSemesterId());
                break;
            }
            case "exam-save": {
                Exam exam = new Exam();
                String idStr = req.getParameter("id");
                exam.setName(req.getParameter("name"));
                exam.setExamType(req.getParameter("examType"));
                exam.setCourseId(Integer.parseInt(req.getParameter("courseId")));
                exam.setSemesterId(Integer.parseInt(req.getParameter("semesterId")));
                exam.setExamDate(req.getParameter("examDate"));
                exam.setStartTime(req.getParameter("startTime"));
                exam.setEndTime(req.getParameter("endTime"));
                exam.setRoom(req.getParameter("room"));
                exam.setBuilding(req.getParameter("building"));
                exam.setMaxMarks(Double.parseDouble(req.getParameter("maxMarks")));
                exam.setPassingMarks(Double.parseDouble(req.getParameter("passingMarks")));
                exam.setInstructions(req.getParameter("instructions"));
                exam.setStatus(req.getParameter("status"));
                exam.setCreatedBy(user.getId());
                if (idStr != null && !idStr.isBlank()) {
                    exam.setId(Integer.parseInt(idStr));
                    academicDAO.updateExam(exam);
                } else {
                    academicDAO.createExam(exam);
                }
                resp.sendRedirect(req.getContextPath() + "/academic/exams?semesterId=" + exam.getSemesterId());
                break;
            }
            case "exam-result-save": {
                int examId = Integer.parseInt(req.getParameter("examId"));
                for (String sid : req.getParameterValues("studentIds")) {
                    String marks = req.getParameter("marks_" + sid);
                    String status = req.getParameter("status_" + sid);
                    if (marks != null && !marks.isBlank()) {
                        ExamResult er = new ExamResult();
                        er.setExamId(examId);
                        er.setStudentId(Integer.parseInt(sid));
                        er.setMarksObtained(Double.parseDouble(marks));
                        er.setStatus(status);
                        er.setGradedBy(user.getId());
                        er.setGradedAt(java.time.LocalDateTime.now().toString());
                        academicDAO.saveExamResult(er);
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/academic/exam-results?examId=" + examId + "&saved=1");
                break;
            }
            case "timetable-delete": {
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    int semId = 0;
                    try {
                        try (Connection c = DBUtil.getConnection();
                             PreparedStatement p = c.prepareStatement("SELECT semester_id FROM timetable WHERE id=?")) {
                            p.setInt(1, Integer.parseInt(idStr));
                            try (ResultSet r = p.executeQuery()) { if (r.next()) semId = r.getInt(1); }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    academicDAO.deleteTimetableEntry(Integer.parseInt(idStr));
                    resp.sendRedirect(req.getContextPath() + "/academic/timetable?semesterId=" + semId);
                }
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/academic/dashboard");
        }
    }
}