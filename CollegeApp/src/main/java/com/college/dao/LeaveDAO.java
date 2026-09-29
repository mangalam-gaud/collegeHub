package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class LeaveDAO {

    public List<LeaveType> getAllLeaveTypes() {
        List<LeaveType> list = new ArrayList<>();
        String sql = "SELECT * FROM leave_types WHERE is_active=1 ORDER BY name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapLeaveType(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<LeaveRequest> getLeaveRequestsByUser(int userId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.name as leave_type_name, u.full_name as reviewed_by_name " +
                     "FROM leave_requests lr " +
                     "JOIN leave_types lt ON lt.id=lr.leave_type_id " +
                     "LEFT JOIN users u ON u.id=lr.reviewed_by " +
                     "WHERE lr.user_id=? ORDER BY lr.applied_at DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapLeaveRequest(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<LeaveRequest> getPendingLeaveRequests(int reviewerId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.name as leave_type_name, u.full_name as user_name, u.role as user_role " +
                     "FROM leave_requests lr " +
                     "JOIN leave_types lt ON lt.id=lr.leave_type_id " +
                     "JOIN users u ON u.id=lr.user_id " +
                     "WHERE lr.status='PENDING' " +
                     "AND (lr.leave_type_id IN (SELECT leave_type_id FROM leave_types WHERE requires_approval=1) " +
                     "OR lr.total_days > 3) " +
                     "ORDER BY lr.applied_at";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapLeaveRequest(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<LeaveRequest> getAllLeaveRequests(String status, int offset, int limit) {
        List<LeaveRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT lr.*, lt.name as leave_type_name, u.full_name as user_name, " +
                "u.role as user_role, u2.full_name as reviewed_by_name " +
                "FROM leave_requests lr " +
                "JOIN leave_types lt ON lt.id=lr.leave_type_id " +
                "JOIN users u ON u.id=lr.user_id " +
                "LEFT JOIN users u2 ON u2.id=lr.reviewed_by WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isBlank()) { sql.append(" AND lr.status=?"); params.add(status); }
        sql.append(" ORDER BY lr.applied_at DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapLeaveRequest(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean submitLeaveRequest(LeaveRequest lr) {
        String sql = "INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, " +
                     "reason, contact_during_leave, status) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, lr.getUserId());
            p.setInt(2, lr.getLeaveTypeId());
            p.setString(3, lr.getStartDate());
            p.setString(4, lr.getEndDate());
            p.setDouble(5, lr.getTotalDays());
            p.setString(6, lr.getReason());
            p.setString(7, lr.getContactDuringLeave());
            p.setString(8, "PENDING");
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) lr.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean reviewLeaveRequest(int requestId, int reviewerId, String status, String remarks) {
        String sql = "UPDATE leave_requests SET status=?, reviewed_by=?, reviewed_at=NOW(), reviewer_remarks=? WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, status);
            p.setInt(2, reviewerId);
            p.setString(3, remarks);
            p.setInt(4, requestId);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private LeaveType mapLeaveType(ResultSet r) throws SQLException {
        LeaveType lt = new LeaveType();
        lt.setId(r.getInt("id"));
        lt.setName(r.getString("name"));
        lt.setCode(r.getString("code"));
        lt.setDescription(r.getString("description"));
        lt.setMaxDaysPerYear(r.getInt("max_days_per_year"));
        lt.setRequiresApproval(r.getInt("requires_approval") == 1);
        lt.setCarryForward(r.getInt("is_carry_forward") == 1);
        lt.setActive(r.getInt("is_active") == 1);
        lt.setCreatedAt(r.getString("created_at"));
        return lt;
    }

    private LeaveRequest mapLeaveRequest(ResultSet r) throws SQLException {
        LeaveRequest lr = new LeaveRequest();
        lr.setId(r.getInt("id"));
        lr.setUserId(r.getInt("user_id"));
        lr.setUserName(r.getString("user_name"));
        lr.setUserRole(r.getString("user_role"));
        lr.setLeaveTypeId(r.getInt("leave_type_id"));
        lr.setLeaveTypeName(r.getString("leave_type_name"));
        lr.setStartDate(r.getString("start_date"));
        lr.setEndDate(r.getString("end_date"));
        lr.setTotalDays(r.getDouble("total_days"));
        lr.setReason(r.getString("reason"));
        lr.setContactDuringLeave(r.getString("contact_during_leave"));
        lr.setStatus(r.getString("status"));
        lr.setAppliedAt(r.getString("applied_at"));
        lr.setReviewedBy(r.getInt("reviewed_by"));
        lr.setReviewedByName(r.getString("reviewed_by_name"));
        lr.setReviewedAt(r.getString("reviewed_at"));
        lr.setReviewerRemarks(r.getString("reviewer_remarks"));
        lr.setSupportingDocument(r.getString("supporting_document"));
        return lr;
    }
}