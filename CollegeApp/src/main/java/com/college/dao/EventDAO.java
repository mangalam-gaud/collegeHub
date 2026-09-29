package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class EventDAO {

    public List<Event> getPublishedEvents(String type, int offset, int limit) {
        List<Event> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT e.*, u.full_name as organizer_name " +
                "FROM events e LEFT JOIN users u ON u.id=e.organizer_id " +
                "WHERE e.is_published=1 AND e.end_datetime >= NOW()");
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isBlank()) { sql.append(" AND e.event_type=?"); params.add(type); }
        sql.append(" ORDER BY e.start_datetime LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapEvent(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Event> getAllEvents(String type, int offset, int limit) {
        List<Event> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT e.*, u.full_name as organizer_name " +
                "FROM events e LEFT JOIN users u ON u.id=e.organizer_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (type != null && !type.isBlank()) { sql.append(" AND e.event_type=?"); params.add(type); }
        sql.append(" ORDER BY e.start_datetime DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapEvent(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Event getEventById(int id) {
        String sql = "SELECT e.*, u.full_name as organizer_name FROM events e " +
                     "LEFT JOIN users u ON u.id=e.organizer_id WHERE e.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapEvent(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<Event> getUpcomingEventsForUser(int userId, String role) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT e.*, u.full_name as organizer_name FROM events e " +
                     "LEFT JOIN users u ON u.id=e.organizer_id " +
                     "WHERE e.is_published=1 AND e.end_datetime >= NOW() " +
                     "AND (e.target_audience='ALL' OR e.target_audience=? " +
                     "OR (e.target_audience='SPECIFIC' AND (e.specific_roles LIKE ? OR e.specific_departments LIKE ?))) " +
                     "ORDER BY e.start_datetime LIMIT 10";
        try {
            try (Connection c = DBUtil.getConnection();
                 PreparedStatement p = c.prepareStatement(sql)) {
                p.setString(1, role);
                p.setString(2, "%" + role + "%");
                p.setString(3, "%" + role + "%");
                try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapEvent(r)); }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list != null ? list : new ArrayList<>();
    }

    public boolean createEvent(Event event) {
        String sql = "INSERT INTO events (title, description, event_type, start_datetime, end_datetime, " +
                     "location, organizer_id, target_audience, specific_roles, specific_departments, " +
                     "specific_courses, max_participants, registration_required, registration_deadline, is_published) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, event.getTitle());
            p.setString(2, event.getDescription());
            p.setString(3, event.getEventType());
            p.setString(4, event.getStartDatetime());
            p.setString(5, event.getEndDatetime());
            p.setString(6, event.getLocation());
            p.setInt(7, event.getOrganizerId());
            p.setString(8, event.getTargetAudience());
            p.setString(9, event.getSpecificRoles());
            p.setString(10, event.getSpecificDepartments());
            p.setString(11, event.getSpecificCourses());
            p.setInt(12, event.getMaxParticipants());
            p.setInt(13, event.isRegistrationRequired() ? 1 : 0);
            p.setString(14, event.getRegistrationDeadline());
            p.setInt(15, event.isPublished() ? 1 : 0);
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) event.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean registerForEvent(int eventId, int userId) {
        String sql = "INSERT INTO event_registrations (event_id, user_id, status) VALUES (?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, eventId);
            p.setInt(2, userId);
            p.setString(3, "REGISTERED");
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean cancelRegistration(int eventId, int userId) {
        String sql = "UPDATE event_registrations SET status='CANCELLED' WHERE event_id=? AND user_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, eventId);
            p.setInt(2, userId);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Event mapEvent(ResultSet r) throws SQLException {
        Event e = new Event();
        e.setId(r.getInt("id"));
        e.setTitle(r.getString("title"));
        e.setDescription(r.getString("description"));
        e.setEventType(r.getString("event_type"));
        e.setStartDatetime(r.getString("start_datetime"));
        e.setEndDatetime(r.getString("end_datetime"));
        e.setLocation(r.getString("location"));
        e.setOrganizerId(r.getInt("organizer_id"));
        e.setOrganizerName(r.getString("organizer_name"));
        e.setTargetAudience(r.getString("target_audience"));
        e.setMaxParticipants(r.getInt("max_participants"));
        e.setRegistrationRequired(r.getInt("registration_required") == 1);
        e.setRegistrationDeadline(r.getString("registration_deadline"));
        e.setPublished(r.getInt("is_published") == 1);
        e.setCreatedAt(r.getString("created_at"));
        return e;
    }
}