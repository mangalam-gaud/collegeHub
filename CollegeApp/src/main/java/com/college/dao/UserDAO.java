package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.User;
import com.college.util.DBUtil;

public class UserDAO {

    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username=? AND active=1";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, username);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) {
                    String stored = r.getString("password_hash");
                    boolean ok;
                    if (stored != null && stored.startsWith("$2")) {
                        // bcrypt (new accounts)
                        ok = DBUtil.verifyPassword(password, stored);
                        // Rehash if cost factor increased
                        String newHash = DBUtil.rehashIfNeeded(password, stored);
                        if (!newHash.equals(stored)) {
                            updatePasswordHash(r.getInt("id"), newHash);
                        }
                    } else {
                        // legacy SHA-256 (seeded admin) — transparently upgraded on login
                        String salt = r.getString("salt");
                        ok = DBUtil.sha256(password, salt).equals(stored);
                        if (ok) upgradeToBcrypt(r.getInt("id"), password);
                    }
                    if (ok) {
                        DBUtil.auditLogin(username, true, null, null);
                        return map(r);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        DBUtil.auditLogin(username, false, null, null);
        return null;
    }

    private void upgradeToBcrypt(int userId, String password) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("UPDATE users SET password_hash=?, salt='bcrypt' WHERE id=?")) {
            p.setString(1, DBUtil.hashPassword(password));
            p.setInt(2, userId);
            p.executeUpdate();
            DBUtil.auditDataChange("users", "PASSWORD_UPGRADE", userId, userId, "SHA-256", "BCRYPT");
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private void updatePasswordHash(int userId, String newHash) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("UPDATE users SET password_hash=? WHERE id=?")) {
            p.setString(1, newHash);
            p.setInt(2, userId);
            p.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public boolean create(User u, String password, String role) {
        String sql = "INSERT INTO users (username,email,password_hash,salt,role,full_name,phone,gender,dob,address) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, u.getUsername());
            p.setString(2, u.getEmail());
            p.setString(3, DBUtil.hashPassword(password));
            p.setString(4, "bcrypt");
            p.setString(5, role);
            p.setString(6, u.getFullName());
            p.setString(7, u.getPhone());
            p.setString(8, u.getGender());
            p.setString(9, u.getDob());
            p.setString(10, u.getAddress());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) {
                        u.setId(keys.getInt(1));
                    }
                }
                DBUtil.auditDataChange("users", "CREATE", u.getId(), null, null, "username=" + u.getUsername());
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean update(User u) {
        String sql = "UPDATE users SET full_name=?, email=?, phone=?, gender=?, dob=?, address=? WHERE id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, u.getFullName());
            p.setString(2, u.getEmail());
            p.setString(3, u.getPhone());
            p.setString(4, u.getGender());
            p.setString(5, u.getDob());
            p.setString(6, u.getAddress());
            p.setInt(7, u.getId());
            boolean ok = p.executeUpdate() == 1;
            if (ok) {
                DBUtil.auditDataChange("users", "UPDATE", u.getId(), u.getId(), null, "fullName=" + u.getFullName());
            }
            return ok;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean changePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password_hash=?, salt='bcrypt' WHERE id=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, DBUtil.hashPassword(newPassword));
            p.setInt(2, userId);
            boolean ok = p.executeUpdate() == 1;
            if (ok) {
                DBUtil.auditDataChange("users", "PASSWORD_CHANGE", userId, userId, null, null);
            }
            return ok;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean setActive(int id, boolean active) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("UPDATE users SET active=? WHERE id=?")) {
            p.setInt(1, active ? 1 : 0);
            p.setInt(2, id);
            boolean ok = p.executeUpdate() == 1;
            if (ok) {
                DBUtil.auditDataChange("users", active ? "ENABLE" : "DISABLE", id, id, null, null);
            }
            return ok;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean delete(int id) {
        // Prevent deletion of ADMIN users
        try (Connection c = DBUtil.getConnection();
             PreparedStatement check = c.prepareStatement("SELECT role FROM users WHERE id=?")) {
            check.setInt(1, id);
            try (ResultSet r = check.executeQuery()) {
                if (r.next() && "ADMIN".equals(r.getString("role"))) {
                    return false; // Cannot delete admin
                }
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }

        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("DELETE FROM users WHERE id=?")) {
            p.setInt(1, id);
            boolean ok = p.executeUpdate() == 1;
            if (ok) {
                DBUtil.auditDataChange("users", "DELETE", id, null, null, null);
            }
            return ok;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public User getById(int id) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT * FROM users WHERE id=?")) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return map(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<User> getByRole(String role) {
        List<User> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT * FROM users WHERE role=? ORDER BY full_name")) {
            p.setString(1, role);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(map(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Search by name/username/email within a role (LIKE-escaped, injection-safe). */
    public List<User> searchByRole(String role, String q) {
        List<User> list = new ArrayList<>();
        if (q == null || q.isBlank()) return getByRole(role);
        String like = "%" + q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
        String sql = "SELECT * FROM users WHERE role=? AND (full_name LIKE ? ESCAPE '\\\\' OR username LIKE ? ESCAPE '\\\\' OR email LIKE ? ESCAPE '\\\\') ORDER BY full_name";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, role);
            p.setString(2, like);
            p.setString(3, like);
            p.setString(4, like);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(map(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Paginated search for large datasets. */
    public List<User> searchByRolePaginated(String role, String q, int offset, int limit) {
        List<User> list = new ArrayList<>();
        String like = "%" + (q == null ? "" : q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")) + "%";
        String sql = "SELECT * FROM users WHERE role=? AND (full_name LIKE ? ESCAPE '\\\\' OR username LIKE ? ESCAPE '\\\\' OR email LIKE ? ESCAPE '\\\\') ORDER BY full_name LIMIT ? OFFSET ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, role);
            p.setString(2, like);
            p.setString(3, like);
            p.setString(4, like);
            p.setInt(5, limit);
            p.setInt(6, offset);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(map(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countByRole(String role) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM users WHERE role=?")) {
            p.setString(1, role);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countByRoleSearch(String role, String q) {
        if (q == null || q.isBlank()) return countByRole(role);
        String like = "%" + q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
        String sql = "SELECT COUNT(*) FROM users WHERE role=? AND (full_name LIKE ? ESCAPE '\\\\' OR username LIKE ? ESCAPE '\\\\' OR email LIKE ? ESCAPE '\\\\')";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, role);
            p.setString(2, like);
            p.setString(3, like);
            p.setString(4, like);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean emailOrUsernameExists(String username, String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE username=? OR email=?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, username); p.setString(2, email);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1) > 0; }
        } catch (SQLException e) { e.printStackTrace(); }
        return true; // fail closed
    }

    public boolean usernameExists(String username) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM users WHERE username=?")) {
            p.setString(1, username);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1) > 0; }
        } catch (SQLException e) { e.printStackTrace(); }
        return true;
    }

    public boolean emailExists(String email) {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM users WHERE email=?")) {
            p.setString(1, email);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1) > 0; }
        } catch (SQLException e) { e.printStackTrace(); }
        return true;
    }

    private User map(ResultSet r) throws SQLException {
        User u = new User();
        u.setId(r.getInt("id"));
        u.setUsername(r.getString("username"));
        u.setEmail(r.getString("email"));
        u.setRole(r.getString("role"));
        u.setFullName(r.getString("full_name"));
        u.setPhone(r.getString("phone"));
        u.setGender(r.getString("gender"));
        u.setDob(r.getString("dob"));
        u.setAddress(r.getString("address"));
        u.setActive(r.getInt("active") == 1);
        return u;
    }
}