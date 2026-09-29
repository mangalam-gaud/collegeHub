package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import com.college.model.*;
import com.college.util.DBUtil;

public class AcademicDAO {

    // ========== Academic Years ==========
    public List<AcademicYear> getAllAcademicYears() {
        List<AcademicYear> list = new ArrayList<>();
        String sql = "SELECT * FROM academic_years ORDER BY start_date DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapAcademicYear(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public AcademicYear getCurrentAcademicYear() {
        String sql = "SELECT * FROM academic_years WHERE is_current=1 AND is_active=1 LIMIT 1";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            if (r.next()) return mapAcademicYear(r);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public AcademicYear getAcademicYearById(int id) {
        String sql = "SELECT * FROM academic_years WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapAcademicYear(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createAcademicYear(AcademicYear ay) {
        String sql = "INSERT INTO academic_years (name, start_date, end_date, is_current, is_active) VALUES (?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, ay.getName());
            p.setString(2, ay.getStartDate());
            p.setString(3, ay.getEndDate());
            p.setInt(4, ay.isCurrent() ? 1 : 0);
            p.setInt(5, ay.isActive() ? 1 : 0);
            if (ay.isCurrent()) {
                clearCurrentAcademicYear(c);
            }
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) ay.setId(keys.getInt(1));
                }
                DBUtil.auditDataChange("academic_years", "CREATE", ay.getId(), null, null, "name=" + ay.getName());
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private void clearCurrentAcademicYear(Connection c) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("UPDATE academic_years SET is_current=0 WHERE is_current=1")) {
            p.executeUpdate();
        }
    }

    private AcademicYear mapAcademicYear(ResultSet r) throws SQLException {
        AcademicYear ay = new AcademicYear();
        ay.setId(r.getInt("id"));
        ay.setName(r.getString("name"));
        ay.setStartDate(r.getString("start_date"));
        ay.setEndDate(r.getString("end_date"));
        ay.setCurrent(r.getInt("is_current") == 1);
        ay.setActive(r.getInt("is_active") == 1);
        ay.setCreatedAt(r.getString("created_at"));
        return ay;
    }

    // ========== Semesters ==========
    public List<Semester> getSemestersByAcademicYear(int academicYearId) {
        List<Semester> list = new ArrayList<>();
        String sql = "SELECT * FROM semesters WHERE academic_year_id=? ORDER BY number";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, academicYearId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapSemester(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Semester getCurrentSemester() {
        String sql = "SELECT s.*, ay.name as academic_year_name FROM semesters s " +
                     "JOIN academic_years ay ON ay.id=s.academic_year_id " +
                     "WHERE s.is_current=1 AND s.is_active=1 AND ay.is_active=1 LIMIT 1";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            if (r.next()) return mapSemester(r);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public Semester getSemesterById(int id) {
        String sql = "SELECT s.*, ay.name as academic_year_name FROM semesters s " +
                     "JOIN academic_years ay ON ay.id=s.academic_year_id WHERE s.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapSemester(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createSemester(Semester s) {
        String sql = "INSERT INTO semesters (academic_year_id, name, number, start_date, end_date, " +
                     "registration_start, registration_end, exam_start, exam_end, break_start, break_end, is_current, is_active) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, s.getAcademicYearId());
            p.setString(2, s.getName());
            p.setInt(3, s.getNumber());
            p.setString(4, s.getStartDate());
            p.setString(5, s.getEndDate());
            p.setString(6, s.getRegistrationStart());
            p.setString(7, s.getRegistrationEnd());
            p.setString(8, s.getExamStart());
            p.setString(9, s.getExamEnd());
            p.setString(10, s.getBreakStart());
            p.setString(11, s.getBreakEnd());
            p.setInt(12, s.isCurrent() ? 1 : 0);
            p.setInt(13, s.isActive() ? 1 : 0);
            if (s.isCurrent()) {
                clearCurrentSemester(c, s.getAcademicYearId());
            }
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) s.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private void clearCurrentSemester(Connection c, int academicYearId) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("UPDATE semesters SET is_current=0 WHERE academic_year_id=? AND is_current=1")) {
            p.setInt(1, academicYearId);
            p.executeUpdate();
        }
    }

    private Semester mapSemester(ResultSet r) throws SQLException {
        Semester s = new Semester();
        s.setId(r.getInt("id"));
        s.setAcademicYearId(r.getInt("academic_year_id"));
        s.setAcademicYearName(r.getString("academic_year_name"));
        s.setName(r.getString("name"));
        s.setNumber(r.getInt("number"));
        s.setStartDate(r.getString("start_date"));
        s.setEndDate(r.getString("end_date"));
        s.setRegistrationStart(r.getString("registration_start"));
        s.setRegistrationEnd(r.getString("registration_end"));
        s.setExamStart(r.getString("exam_start"));
        s.setExamEnd(r.getString("exam_end"));
        s.setBreakStart(r.getString("break_start"));
        s.setBreakEnd(r.getString("break_end"));
        s.setCurrent(r.getInt("is_current") == 1);
        s.setActive(r.getInt("is_active") == 1);
        s.setCreatedAt(r.getString("created_at"));
        return s;
    }

    // ========== Timetable Slots ==========
    public List<TimetableSlot> getAllTimetableSlots() {
        List<TimetableSlot> list = new ArrayList<>();
        String sql = "SELECT * FROM timetable_slots ORDER BY day_of_week, slot_order";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapTimetableSlot(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private TimetableSlot mapTimetableSlot(ResultSet r) throws SQLException {
        TimetableSlot ts = new TimetableSlot();
        ts.setId(r.getInt("id"));
        ts.setName(r.getString("name"));
        ts.setStartTime(r.getString("start_time"));
        ts.setEndTime(r.getString("end_time"));
        ts.setDayOfWeek(r.getString("day_of_week"));
        ts.setSlotOrder(r.getInt("slot_order"));
        ts.setBreak(r.getInt("is_break") == 1);
        ts.setCreatedAt(r.getString("created_at"));
        return ts;
    }

    // ========== Timetable ==========
    public List<Timetable> getTimetableBySemester(int semesterId) {
        List<Timetable> list = new ArrayList<>();
        String sql = "SELECT t.*, c.code as course_code, c.title as course_title, " +
                     "ts.name as slot_name, ts.day_of_week, ts.start_time, ts.end_time " +
                     "FROM timetable t " +
                     "JOIN courses c ON c.id=t.course_id " +
                     "JOIN timetable_slots ts ON ts.id=t.slot_id " +
                     "WHERE t.semester_id=? ORDER BY ts.day_of_week, ts.slot_order";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, semesterId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapTimetable(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Timetable> getTimetableByTeacher(int teacherId, int semesterId) {
        List<Timetable> list = new ArrayList<>();
        String sql = "SELECT t.*, c.code as course_code, c.title as course_title, " +
                     "ts.name as slot_name, ts.day_of_week, ts.start_time, ts.end_time " +
                     "FROM timetable t " +
                     "JOIN courses c ON c.id=t.course_id " +
                     "JOIN timetable_slots ts ON ts.id=t.slot_id " +
                     "WHERE c.teacher_id=? AND t.semester_id=? ORDER BY ts.day_of_week, ts.slot_order";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, teacherId);
            p.setInt(2, semesterId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapTimetable(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Timetable> getTimetableByStudent(int studentId, int semesterId) {
        List<Timetable> list = new ArrayList<>();
        String sql = "SELECT t.*, c.code as course_code, c.title as course_title, " +
                     "ts.name as slot_name, ts.day_of_week, ts.start_time, ts.end_time " +
                     "FROM timetable t " +
                     "JOIN courses c ON c.id=t.course_id " +
                     "JOIN timetable_slots ts ON ts.id=t.slot_id " +
                     "JOIN enrollments e ON e.course_id=c.id AND e.student_id=? AND e.status='ENROLLED' " +
                     "WHERE t.semester_id=? ORDER BY ts.day_of_week, ts.slot_order";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            p.setInt(2, semesterId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapTimetable(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean createTimetableEntry(Timetable t) {
        String sql = "INSERT INTO timetable (course_id, semester_id, slot_id, room, building, effective_from, effective_to, is_recurring, created_by) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, t.getCourseId());
            p.setInt(2, t.getSemesterId());
            p.setInt(3, t.getSlotId());
            p.setString(4, t.getRoom());
            p.setString(5, t.getBuilding());
            p.setString(6, t.getEffectiveFrom());
            p.setString(7, t.getEffectiveTo());
            p.setInt(8, t.isRecurring() ? 1 : 0);
            p.setInt(9, t.getCreatedBy());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteTimetableEntry(int id) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("DELETE FROM timetable WHERE id=?")) {
            p.setInt(1, id);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Timetable mapTimetable(ResultSet r) throws SQLException {
        Timetable t = new Timetable();
        t.setId(r.getInt("id"));
        t.setCourseId(r.getInt("course_id"));
        t.setCourseCode(r.getString("course_code"));
        t.setCourseTitle(r.getString("course_title"));
        t.setSemesterId(r.getInt("semester_id"));
        t.setSlotId(r.getInt("slot_id"));
        t.setSlotName(r.getString("slot_name"));
        t.setDayOfWeek(r.getString("day_of_week"));
        t.setStartTime(r.getString("start_time"));
        t.setEndTime(r.getString("end_time"));
        t.setRoom(r.getString("room"));
        t.setBuilding(r.getString("building"));
        t.setEffectiveFrom(r.getString("effective_from"));
        t.setEffectiveTo(r.getString("effective_to"));
        t.setRecurring(r.getInt("is_recurring") == 1);
        t.setCreatedAt(r.getString("created_at"));
        return t;
    }

    // ========== Exams ==========
    public List<Exam> getExamsBySemester(int semesterId) {
        List<Exam> list = new ArrayList<>();
        String sql = "SELECT e.*, c.code as course_code, c.title as course_title, " +
                     "ay.name as academic_year_name " +
                     "FROM exams e " +
                     "JOIN courses c ON c.id=e.course_id " +
                     "JOIN semesters s ON s.id=e.semester_id " +
                     "JOIN academic_years ay ON ay.id=s.academic_year_id " +
                     "WHERE e.semester_id=? ORDER BY e.exam_date, e.start_time";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, semesterId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapExam(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Exam> getExamsByTeacher(int teacherId, int semesterId) {
        List<Exam> list = new ArrayList<>();
        String sql = "SELECT e.*, c.code as course_code, c.title as course_title " +
                     "FROM exams e " +
                     "JOIN courses c ON c.id=e.course_id " +
                     "WHERE c.teacher_id=? AND e.semester_id=? ORDER BY e.exam_date, e.start_time";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, teacherId);
            p.setInt(2, semesterId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapExam(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Exam> getExamsByStudent(int studentId, int semesterId) {
        List<Exam> list = new ArrayList<>();
        String sql = "SELECT e.*, c.code as course_code, c.title as course_title, " +
                     "er.marks_obtained, er.status as result_status " +
                     "FROM exams e " +
                     "JOIN courses c ON c.id=e.course_id " +
                     "JOIN enrollments en ON en.course_id=c.id AND en.student_id=? AND en.status='ENROLLED' " +
                     "LEFT JOIN exam_results er ON er.exam_id=e.id AND er.student_id=? " +
                     "WHERE e.semester_id=? ORDER BY e.exam_date, e.start_time";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            p.setInt(2, studentId);
            p.setInt(3, semesterId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapExam(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Exam getExamById(int id) {
        String sql = "SELECT e.*, c.code as course_code, c.title as course_title FROM exams e " +
                     "JOIN courses c ON c.id=e.course_id WHERE e.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapExam(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createExam(Exam exam) {
        String sql = "INSERT INTO exams (name, exam_type, course_id, semester_id, exam_date, start_time, end_time, " +
                     "room, building, max_marks, passing_marks, instructions, status, created_by) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, exam.getName());
            p.setString(2, exam.getExamType());
            p.setInt(3, exam.getCourseId());
            p.setInt(4, exam.getSemesterId());
            p.setString(5, exam.getExamDate());
            p.setString(6, exam.getStartTime());
            p.setString(7, exam.getEndTime());
            p.setString(8, exam.getRoom());
            p.setString(9, exam.getBuilding());
            p.setDouble(10, exam.getMaxMarks());
            p.setDouble(11, exam.getPassingMarks());
            p.setString(12, exam.getInstructions());
            p.setString(13, exam.getStatus());
            p.setInt(14, exam.getCreatedBy());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) exam.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateExam(Exam exam) {
        String sql = "UPDATE exams SET name=?, exam_type=?, exam_date=?, start_time=?, end_time=?, room=?, building=?, " +
                     "max_marks=?, passing_marks=?, instructions=?, status=? WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, exam.getName());
            p.setString(2, exam.getExamType());
            p.setString(3, exam.getExamDate());
            p.setString(4, exam.getStartTime());
            p.setString(5, exam.getEndTime());
            p.setString(6, exam.getRoom());
            p.setString(7, exam.getBuilding());
            p.setDouble(8, exam.getMaxMarks());
            p.setDouble(9, exam.getPassingMarks());
            p.setString(10, exam.getInstructions());
            p.setString(11, exam.getStatus());
            p.setInt(12, exam.getId());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Exam mapExam(ResultSet r) throws SQLException {
        Exam e = new Exam();
        e.setId(r.getInt("id"));
        e.setName(r.getString("name"));
        e.setExamType(r.getString("exam_type"));
        e.setCourseId(r.getInt("course_id"));
        e.setCourseCode(r.getString("course_code"));
        e.setCourseTitle(r.getString("course_title"));
        e.setSemesterId(r.getInt("semester_id"));
        e.setExamDate(r.getString("exam_date"));
        e.setStartTime(r.getString("start_time"));
        e.setEndTime(r.getString("end_time"));
        e.setRoom(r.getString("room"));
        e.setBuilding(r.getString("building"));
        e.setMaxMarks(r.getDouble("max_marks"));
        e.setPassingMarks(r.getDouble("passing_marks"));
        e.setInstructions(r.getString("instructions"));
        e.setStatus(r.getString("status"));
        e.setCreatedAt(r.getString("created_at"));
        return e;
    }

    // ========== Exam Results ==========
    public List<ExamResult> getExamResults(int examId) {
        List<ExamResult> list = new ArrayList<>();
        String sql = "SELECT er.*, u.full_name as student_name, u.username as student_username " +
                     "FROM exam_results er " +
                     "JOIN users u ON u.id=er.student_id " +
                     "WHERE er.exam_id=? ORDER BY u.full_name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, examId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapExamResult(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<ExamResult> getStudentExamResults(int studentId) {
        List<ExamResult> list = new ArrayList<>();
        String sql = "SELECT er.*, e.name as exam_name, e.exam_type, e.max_marks " +
                     "FROM exam_results er " +
                     "JOIN exams e ON e.id=er.exam_id " +
                     "WHERE er.student_id=? ORDER BY e.exam_date DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapExamResult(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean saveExamResult(ExamResult result) {
        String sql = "INSERT INTO exam_results (exam_id, student_id, marks_obtained, status, graded_by, graded_at, remarks) " +
                     "VALUES (?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE marks_obtained=VALUES(marks_obtained), " +
                     "status=VALUES(status), graded_by=VALUES(graded_by), graded_at=VALUES(graded_at), remarks=VALUES(remarks)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, result.getExamId());
            p.setInt(2, result.getStudentId());
            if (result.getMarksObtained() >= 0) p.setDouble(3, result.getMarksObtained());
            else p.setNull(3, Types.DECIMAL);
            p.setString(4, result.getStatus());
            p.setInt(5, result.getGradedBy());
            p.setTimestamp(6, result.getGradedAt() != null ? Timestamp.valueOf(result.getGradedAt()) : null);
            p.setString(7, result.getRemarks());
            return p.executeUpdate() >= 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ========== Notices ==========
    public List<Notice> getNotices(String audience) {
        List<Notice> list = new ArrayList<>();
        String sql = "SELECT n.*, u.full_name AS author FROM notices n JOIN users u ON u.id=n.posted_by " +
                     "WHERE n.audience='ALL' OR n.audience=? ORDER BY n.created_at DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, audience);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapNotice(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean createNotice(Notice n, int postedBy) {
        String sql = "INSERT INTO notices (title, body, posted_by, audience) VALUES (?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, n.getTitle()); p.setString(2, n.getBody());
            p.setInt(3, postedBy); p.setString(4, n.getAudience());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteNotice(int id) {
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement("DELETE FROM notices WHERE id=?")) {
            p.setInt(1, id);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private ExamResult mapExamResult(ResultSet r) throws SQLException {
        ExamResult er = new ExamResult();
        er.setId(r.getInt("id"));
        er.setExamId(r.getInt("exam_id"));
        er.setExamName(r.getString("exam_name"));
        er.setExamType(r.getString("exam_type"));
        er.setStudentId(r.getInt("student_id"));
        er.setStudentName(r.getString("student_name"));
        er.setStudentUsername(r.getString("student_username"));
        er.setMarksObtained(r.getDouble("marks_obtained"));
        er.setMaxMarks(r.getDouble("max_marks"));
        if (er.getMaxMarks() > 0) {
            er.setPercentage(Math.round(er.getMarksObtained() * 1000.0 / er.getMaxMarks()) / 10.0);
        }
        er.setStatus(r.getString("status"));
        er.setGradedBy(r.getInt("graded_by"));
        er.setGradedAt(r.getString("graded_at"));
        er.setRemarks(r.getString("remarks"));
        er.setCreatedAt(r.getString("created_at"));
        return er;
    }

    private Notice mapNotice(ResultSet r) throws SQLException {
        Notice n = new Notice();
        n.setId(r.getInt("id"));
        n.setTitle(r.getString("title"));
        n.setBody(r.getString("body"));
        n.setAudience(r.getString("audience"));
        n.setAuthorName(r.getString("author"));
        Timestamp ts = r.getTimestamp("created_at");
        n.setCreatedAt(ts == null ? "" : ts.toLocalDateTime().toLocalDate().toString());
        return n;
    }

    // ========== Attendance ==========
    public List<Map<String, String>> getEnrolledStudents(int courseId) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT u.id, u.full_name, u.username FROM enrollments e JOIN users u ON u.id=e.student_id WHERE e.course_id=? AND e.status='ENROLLED' ORDER BY u.full_name";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, courseId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Map<String, String> m = new LinkedHashMap<>();
                    m.put("id", String.valueOf(r.getInt("id")));
                    m.put("name", r.getString("full_name"));
                    m.put("username", r.getString("username"));
                    list.add(m);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean markAttendance(int studentId, int courseId, String date, String status, int markedBy) {
        String sql = "INSERT INTO attendance (student_id,course_id,att_date,status,marked_by) VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE status=VALUES(status), marked_by=VALUES(marked_by)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId); p.setInt(2, courseId); p.setString(3, date); p.setString(4, status); p.setInt(5, markedBy);
            return p.executeUpdate() >= 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<Map<String, Object>> getAttendanceSummary(int studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.code, c.title, SUM(a.status='PRESENT') AS attended, COUNT(*) AS total FROM attendance a JOIN courses c ON c.id=a.course_id WHERE a.student_id=? GROUP BY a.course_id, c.code, c.title ORDER BY c.code";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("code", r.getString("code"));
                    m.put("title", r.getString("title"));
                    m.put("attended", r.getInt("attended"));
                    m.put("total", r.getInt("total"));
                    int total = r.getInt("total");
                    m.put("pct", total == 0 ? 0 : Math.round(r.getInt("attended") * 1000.0 / total) / 10.0);
                    list.add(m);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ========== Marks ==========
    public boolean saveMark(int studentId, int courseId, String examType, double marks, double maxMarks, int enteredBy) {
        String sql = "INSERT INTO marks (student_id,course_id,exam_type,marks_obtained,max_marks,entered_by) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE marks_obtained=VALUES(marks_obtained), max_marks=VALUES(max_marks), entered_by=VALUES(entered_by)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId); p.setInt(2, courseId); p.setString(3, examType);
            p.setDouble(4, marks); p.setDouble(5, maxMarks); p.setInt(6, enteredBy);
            return p.executeUpdate() >= 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<Map<String, Object>> getMarks(int studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.code, c.title, m.exam_type, m.marks_obtained, m.max_marks FROM marks m JOIN courses c ON c.id=m.course_id WHERE m.student_id=? ORDER BY c.code, m.exam_type";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("code", r.getString("code"));
                    m.put("title", r.getString("title"));
                    m.put("examType", r.getString("exam_type"));
                    m.put("marks", r.getDouble("marks_obtained"));
                    m.put("max", r.getDouble("max_marks"));
                    list.add(m);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String, Object>> getCourseMarks(int courseId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.full_name, u.username, m.exam_type, m.marks_obtained, m.max_marks FROM marks m JOIN users u ON u.id=m.student_id WHERE m.course_id=? ORDER BY u.full_name";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, courseId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("name", r.getString("full_name"));
                    m.put("username", r.getString("username"));
                    m.put("examType", r.getString("exam_type"));
                    m.put("marks", r.getDouble("marks_obtained"));
                    m.put("max", r.getDouble("max_marks"));
                    list.add(m);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}