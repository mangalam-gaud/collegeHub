package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class HostelDAO {

    public List<Hostel> getAllHostels() {
        List<Hostel> list = new ArrayList<>();
        String sql = "SELECT h.*, u.full_name as warden_name FROM hostels h " +
                     "LEFT JOIN users u ON u.id=h.warden_id WHERE h.is_active=1 ORDER BY h.name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapHostel(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Hostel getHostelById(int id) {
        String sql = "SELECT h.*, u.full_name as warden_name FROM hostels h " +
                     "LEFT JOIN users u ON u.id=h.warden_id WHERE h.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapHostel(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<HostelRoom> getRoomsByHostel(int hostelId) {
        List<HostelRoom> list = new ArrayList<>();
        String sql = "SELECT * FROM hostel_rooms WHERE hostel_id=? ORDER BY room_number";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, hostelId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapRoom(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<HostelRoom> getAvailableRooms(int hostelId) {
        List<HostelRoom> list = new ArrayList<>();
        String sql = "SELECT * FROM hostel_rooms WHERE hostel_id=? AND status IN ('AVAILABLE','PARTIAL') AND occupied_beds < capacity ORDER BY room_number";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, hostelId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapRoom(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public HostelRoom getRoomById(int id) {
        String sql = "SELECT hr.*, h.name as hostel_name FROM hostel_rooms hr " +
                     "JOIN hostels h ON h.id=hr.hostel_id WHERE hr.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapRoom(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createHostel(Hostel h) {
        String sql = "INSERT INTO hostels (name, code, type, warden_id, address, total_rooms, total_beds, " +
                     "facilities, rules, contact_phone, contact_email, is_active) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, h.getName());
            p.setString(2, h.getCode());
            p.setString(3, h.getType());
            p.setInt(4, h.getWardenId());
            p.setString(5, h.getAddress());
            p.setInt(6, h.getTotalRooms());
            p.setInt(7, h.getTotalBeds());
            p.setString(8, h.getFacilities());
            p.setString(9, h.getRules());
            p.setString(10, h.getContactPhone());
            p.setString(11, h.getContactEmail());
            p.setInt(12, h.isActive() ? 1 : 0);
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) h.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean createRoom(HostelRoom room) {
        String sql = "INSERT INTO hostel_rooms (hostel_id, room_number, floor, room_type, capacity, " +
                     "rent_per_month, has_ac, has_attached_bathroom, furniture_details, status) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, room.getHostelId());
            p.setString(2, room.getRoomNumber());
            p.setInt(3, room.getFloor());
            p.setString(4, room.getRoomType());
            p.setInt(5, room.getCapacity());
            p.setDouble(6, room.getRentPerMonth());
            p.setInt(7, room.isHasAc() ? 1 : 0);
            p.setInt(8, room.isHasAttachedBathroom() ? 1 : 0);
            p.setString(9, room.getFurnitureDetails());
            p.setString(10, room.getStatus());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) room.setId(keys.getInt(1));
                }
                // Update hostel totals
                updateHostelTotals(room.getHostelId());
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean allocateRoom(int studentId, int roomId, int bedNumber, int academicYearId, int allocatedBy) {
        Connection c = null;
        try {
            c = DBUtil.getConnection();
            c.setAutoCommit(false);
            
            // Check availability
            String checkSql = "SELECT occupied_beds, capacity FROM hostel_rooms WHERE id=? FOR UPDATE";
            int occupied = 0, capacity = 0;
            try (PreparedStatement p = c.prepareStatement(checkSql)) {
                p.setInt(1, roomId);
                try (ResultSet r = p.executeQuery()) { 
                    if (r.next()) { occupied = r.getInt("occupied_beds"); capacity = r.getInt("capacity"); }
                    else { c.rollback(); return false; }
                }
            }
            if (occupied >= capacity) { c.rollback(); return false; }
            
            // Check if student already has active allocation
            String existingSql = "SELECT id FROM hostel_allocations WHERE student_id=? AND status='ACTIVE'";
            try (PreparedStatement p = c.prepareStatement(existingSql)) {
                p.setInt(1, studentId);
                try (ResultSet r = p.executeQuery()) { if (r.next()) { c.rollback(); return false; } }
            }
            
            // Create allocation
            String allocSql = "INSERT INTO hostel_allocations (student_id, room_id, bed_number, allocated_date, " +
                              "academic_year_id, status, allocated_by) VALUES (?,?,?,CURDATE(),?,?,?)";
            try (PreparedStatement p = c.prepareStatement(allocSql)) {
                p.setInt(1, studentId);
                p.setInt(2, roomId);
                p.setInt(3, bedNumber);
                p.setInt(4, academicYearId);
                p.setString(5, "ACTIVE");
                p.setInt(6, allocatedBy);
                if (p.executeUpdate() != 1) { c.rollback(); return false; }
            }
            
            // Update room occupancy
            String updRoom = "UPDATE hostel_rooms SET occupied_beds=occupied_beds+1, " +
                             "status=CASE WHEN occupied_beds+1>=capacity THEN 'OCCUPIED' ELSE 'PARTIAL' END WHERE id=?";
            try (PreparedStatement p = c.prepareStatement(updRoom)) {
                p.setInt(1, roomId);
                p.executeUpdate();
            }
            
            c.commit();
            return true;
        } catch (SQLException e) { 
            try { if (c != null) c.rollback(); } catch (SQLException ex) {}
            e.printStackTrace(); return false; 
        } finally {
            try { if (c != null) c.setAutoCommit(true); } catch (SQLException e) {}
        }
    }

    public List<HostelRoom> getStudentAllocation(int studentId) {
        List<HostelRoom> list = new ArrayList<>();
        String sql = "SELECT hr.*, h.name as hostel_name, ha.bed_number, ha.allocated_date " +
                     "FROM hostel_allocations ha " +
                     "JOIN hostel_rooms hr ON hr.id=ha.room_id " +
                     "JOIN hostels h ON h.id=hr.hostel_id " +
                     "WHERE ha.student_id=? AND ha.status='ACTIVE'";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapRoom(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private void updateHostelTotals(int hostelId) {
        String sql = "UPDATE hostels h SET " +
                     "total_rooms=(SELECT COUNT(*) FROM hostel_rooms WHERE hostel_id=h.id), " +
                     "total_beds=(SELECT COALESCE(SUM(capacity),0) FROM hostel_rooms WHERE hostel_id=h.id) " +
                     "WHERE h.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, hostelId);
            p.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    private Hostel mapHostel(ResultSet r) throws SQLException {
        Hostel h = new Hostel();
        h.setId(r.getInt("id"));
        h.setName(r.getString("name"));
        h.setCode(r.getString("code"));
        h.setType(r.getString("type"));
        h.setWardenId(r.getInt("warden_id"));
        h.setWardenName(r.getString("warden_name"));
        h.setAddress(r.getString("address"));
        h.setTotalRooms(r.getInt("total_rooms"));
        h.setTotalBeds(r.getInt("total_beds"));
        h.setFacilities(r.getString("facilities"));
        h.setRules(r.getString("rules"));
        h.setContactPhone(r.getString("contact_phone"));
        h.setContactEmail(r.getString("contact_email"));
        h.setActive(r.getInt("is_active") == 1);
        h.setCreatedAt(r.getString("created_at"));
        return h;
    }

    private HostelRoom mapRoom(ResultSet r) throws SQLException {
        HostelRoom hr = new HostelRoom();
        hr.setId(r.getInt("id"));
        hr.setHostelId(r.getInt("hostel_id"));
        hr.setHostelName(r.getString("hostel_name"));
        hr.setRoomNumber(r.getString("room_number"));
        hr.setFloor(r.getInt("floor"));
        hr.setRoomType(r.getString("room_type"));
        hr.setCapacity(r.getInt("capacity"));
        hr.setOccupiedBeds(r.getInt("occupied_beds"));
        hr.setRentPerMonth(r.getDouble("rent_per_month"));
        hr.setHasAc(r.getInt("has_ac") == 1);
        hr.setHasAttachedBathroom(r.getInt("has_attached_bathroom") == 1);
        hr.setFurnitureDetails(r.getString("furniture_details"));
        hr.setStatus(r.getString("status"));
        hr.setCreatedAt(r.getString("created_at"));
        return hr;
    }
}