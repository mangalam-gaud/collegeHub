package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.Program;
import com.college.util.DBUtil;

public class ProgramDAO {

    public List<Program> getAllPrograms() {
        List<Program> list = new ArrayList<>();
        String sql = "SELECT p.*, d.name as department_name FROM programs p " +
                     "LEFT JOIN departments d ON d.id=p.department_id ORDER BY p.name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet r = ps.executeQuery()) {
            while (r.next()) list.add(mapProgram(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Program getProgramById(int id) {
        String sql = "SELECT p.*, d.name as department_name FROM programs p " +
                     "LEFT JOIN departments d ON d.id=p.department_id WHERE p.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet r = ps.executeQuery()) { if (r.next()) return mapProgram(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<Program> getProgramsByDepartment(int departmentId) {
        List<Program> list = new ArrayList<>();
        String sql = "SELECT * FROM programs WHERE department_id=? ORDER BY name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet r = ps.executeQuery()) { while (r.next()) list.add(mapProgram(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean createProgram(Program program) {
        String sql = "INSERT INTO programs (code, name, department_id, duration_years, total_semesters, eligibility_criteria) VALUES (?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, program.getCode());
            ps.setString(2, program.getName());
            ps.setInt(3, program.getDepartmentId());
            ps.setInt(4, program.getDurationYears());
            ps.setInt(5, program.getTotalSemesters());
            ps.setString(6, program.getEligibilityCriteria());
            int affected = ps.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) program.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateProgram(Program program) {
        String sql = "UPDATE programs SET code=?, name=?, department_id=?, duration_years=?, total_semesters=?, eligibility_criteria=? WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, program.getCode());
            ps.setString(2, program.getName());
            ps.setInt(3, program.getDepartmentId());
            ps.setInt(4, program.getDurationYears());
            ps.setInt(5, program.getTotalSemesters());
            ps.setString(6, program.getEligibilityCriteria());
            ps.setInt(7, program.getId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Program mapProgram(ResultSet r) throws SQLException {
        Program p = new Program();
        p.setId(r.getInt("id"));
        p.setCode(r.getString("code"));
        p.setName(r.getString("name"));
        p.setDepartmentId(r.getInt("department_id"));
        p.setDepartmentName(r.getString("department_name"));
        p.setDurationYears(r.getInt("duration_years"));
        p.setTotalSemesters(r.getInt("total_semesters"));
        p.setEligibilityCriteria(r.getString("eligibility_criteria"));
        p.setCreatedAt(r.getString("created_at"));
        return p;
    }
}