package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.Course;
import com.college.util.DBUtil;

public class CourseDAO {

    public List<Course> findAll() {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS teacher_name FROM courses c " +
                     "LEFT JOIN users u ON c.teacher_id=u.id ORDER BY c.code";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(map(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Course> findByTeacher(int teacherId) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS teacher_name FROM courses c " +
                     "LEFT JOIN users u ON c.teacher_id=u.id WHERE c.teacher_id=? ORDER BY c.code";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, teacherId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(map(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Course> findByStudent(int studentId) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS teacher_name FROM courses c " +
                     "JOIN enrollments e ON e.course_id=c.id AND e.student_id=? " +
                     "LEFT JOIN users u ON c.teacher_id=u.id ORDER BY c.code";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(map(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Course> findNotEnrolledByStudent(int studentId) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS teacher_name FROM courses c " +
                     "LEFT JOIN users u ON c.teacher_id=u.id " +
                     "WHERE c.id NOT IN (SELECT course_id FROM enrollments WHERE student_id=?) ORDER BY c.code";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(map(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Course findById(int id) {
        String sql = "SELECT c.*, u.full_name AS teacher_name FROM courses c " +
                     "LEFT JOIN users u ON c.teacher_id=u.id WHERE c.id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return map(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    private Course map(ResultSet r) throws SQLException {
        Course c = new Course();
        c.setId(r.getInt("id"));
        c.setCode(r.getString("code"));
        c.setTitle(r.getString("title"));
        c.setCredits(r.getInt("credits"));
        c.setSemester(r.getInt("semester"));
        int tid = r.getInt("teacher_id");
        c.setTeacherId(r.wasNull() ? null : tid);
        c.setTeacherName(r.getString("teacher_name"));
        return c;
    }

    public boolean create(Course course) {
        String sql = "INSERT INTO courses (code,title,credits,semester,teacher_id) VALUES (?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, course.getCode());
            p.setString(2, course.getTitle());
            p.setInt(3, course.getCredits());
            p.setInt(4, course.getSemester());
            if (course.getTeacherId() != null && course.getTeacherId() > 0) p.setInt(5, course.getTeacherId());
            else p.setNull(5, Types.INTEGER);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean update(Course course) {
        String sql = "UPDATE courses SET code=?, title=?, credits=?, semester=?, teacher_id=? WHERE id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, course.getCode());
            p.setString(2, course.getTitle());
            p.setInt(3, course.getCredits());
            p.setInt(4, course.getSemester());
            if (course.getTeacherId() != null && course.getTeacherId() > 0) p.setInt(5, course.getTeacherId());
            else p.setNull(5, Types.INTEGER);
            p.setInt(6, course.getId());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean delete(int id) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("DELETE FROM courses WHERE id=?")) {
            p.setInt(1, id);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean enroll(int studentId, int courseId) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("INSERT IGNORE INTO enrollments (student_id,course_id) VALUES (?,?)")) {
            p.setInt(1, studentId);
            p.setInt(2, courseId);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean unenroll(int studentId, int courseId) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("DELETE FROM enrollments WHERE student_id=? AND course_id=?")) {
            p.setInt(1, studentId);
            p.setInt(2, courseId);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public int countCourses() {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM courses");
             ResultSet r = p.executeQuery()) {
            if (r.next()) return r.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}
