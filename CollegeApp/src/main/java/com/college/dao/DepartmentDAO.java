package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.Department;
import com.college.util.DBUtil;

public class DepartmentDAO {

    public List<Department> getAllDepartments() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT d.*, u.full_name as hod_name FROM departments d " +
                     "LEFT JOIN users u ON u.id=d.hod_id ORDER BY d.name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapDepartment(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Department getDepartmentById(int id) {
        String sql = "SELECT d.*, u.full_name as hod_name FROM departments d " +
                     "LEFT JOIN users u ON u.id=d.hod_id WHERE d.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapDepartment(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createDepartment(Department d) {
        String sql = "INSERT INTO departments (name, code, hod_id, description) VALUES (?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, d.getName());
            p.setString(2, d.getCode());
            p.setInt(3, d.getHodId());
            p.setString(4, d.getDescription());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) d.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateDepartment(Department d) {
        String sql = "UPDATE departments SET name=?, code=?, hod_id=?, description=? WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, d.getName());
            p.setString(2, d.getCode());
            p.setInt(3, d.getHodId());
            p.setString(4, d.getDescription());
            p.setInt(5, d.getId());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Department mapDepartment(ResultSet r) throws SQLException {
        Department d = new Department();
        d.setId(r.getInt("id"));
        d.setName(r.getString("name"));
        d.setCode(r.getString("code"));
        d.setHodId(r.getInt("hod_id"));
        d.setHodName(r.getString("hod_name"));
        d.setDescription(r.getString("description"));
        d.setCreatedAt(r.getString("created_at"));
        return d;
    }
}