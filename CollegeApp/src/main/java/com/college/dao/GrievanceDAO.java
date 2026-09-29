package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class GrievanceDAO {

    public List<Grievance> getGrievancesByStudent(int studentId) {
        List<Grievance> list = new ArrayList<>();
        String sql = "SELECT g.*, u.full_name as assigned_to_name FROM grievances g " +
                     "LEFT JOIN users u ON u.id=g.assigned_to " +
                     "WHERE g.student_id=? ORDER BY g.created_at DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapGrievance(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Grievance> getAllGrievances(String status, String category, int offset, int limit) {
        List<Grievance> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT g.*, u.full_name as student_name, u.username as student_username, " +
                "u2.full_name as assigned_to_name FROM grievances g " +
                "JOIN users u ON u.id=g.student_id " +
                "LEFT JOIN users u2 ON u2.id=g.assigned_to WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isBlank()) { sql.append(" AND g.status=?"); params.add(status); }
        if (category != null && !category.isBlank()) { sql.append(" AND g.category=?"); params.add(category); }
        sql.append(" ORDER BY g.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapGrievance(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Grievance getGrievanceById(int id) {
        String sql = "SELECT g.*, u.full_name as student_name, u.username as student_username, " +
                     "u2.full_name as assigned_to_name FROM grievances g " +
                     "JOIN users u ON u.id=g.student_id " +
                     "LEFT JOIN users u2 ON u2.id=g.assigned_to WHERE g.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapGrievance(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean submitGrievance(Grievance g) {
        String sql = "INSERT INTO grievances (student_id, category, subject, description, priority, status, is_anonymous, attachment_path) " +
                     "VALUES (?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, g.getStudentId());
            p.setString(2, g.getCategory());
            p.setString(3, g.getSubject());
            p.setString(4, g.getDescription());
            p.setString(5, g.getPriority());
            p.setString(6, "SUBMITTED");
            p.setInt(7, g.isAnonymous() ? 1 : 0);
            p.setString(8, g.getAttachmentPath());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) g.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateGrievance(Grievance g) {
        String sql = "UPDATE grievances SET category=?, subject=?, description=?, priority=?, status=?, " +
                     "assigned_to=?, resolution=?, resolved_at=?, satisfaction_rating=?, feedback_text=?, " +
                     "is_anonymous=?, attachment_path=? WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, g.getCategory());
            p.setString(2, g.getSubject());
            p.setString(3, g.getDescription());
            p.setString(4, g.getPriority());
            p.setString(5, g.getStatus());
            p.setInt(6, g.getAssignedTo());
            p.setString(7, g.getResolution());
            p.setString(8, g.getResolvedAt());
            p.setInt(9, g.getSatisfactionRating());
            p.setString(10, g.getFeedbackText());
            p.setInt(11, g.isAnonymous() ? 1 : 0);
            p.setString(12, g.getAttachmentPath());
            p.setInt(13, g.getId());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Grievance mapGrievance(ResultSet r) throws SQLException {
        Grievance g = new Grievance();
        g.setId(r.getInt("id"));
        g.setStudentId(r.getInt("student_id"));
        g.setStudentName(r.getString("student_name"));
        g.setStudentUsername(r.getString("student_username"));
        g.setCategory(r.getString("category"));
        g.setSubject(r.getString("subject"));
        g.setDescription(r.getString("description"));
        g.setPriority(r.getString("priority"));
        g.setStatus(r.getString("status"));
        g.setAssignedTo(r.getInt("assigned_to"));
        g.setAssignedToName(r.getString("assigned_to_name"));
        g.setResolution(r.getString("resolution"));
        g.setResolvedAt(r.getString("resolved_at"));
        g.setSatisfactionRating(r.getInt("satisfaction_rating"));
        g.setFeedbackText(r.getString("feedback_text"));
        g.setAttachmentPath(r.getString("attachment_path"));
        g.setAnonymous(r.getInt("is_anonymous") == 1);
        g.setCreatedAt(r.getString("created_at"));
        return g;
    }
}