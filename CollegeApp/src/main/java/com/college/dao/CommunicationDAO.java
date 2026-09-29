package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class CommunicationDAO {

    // ========== Messages ==========
    public List<Message> getInbox(int userId, int offset, int limit) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, u.full_name as sender_name, u.role as sender_role " +
                     "FROM messages m " +
                     "JOIN users u ON u.id=m.sender_id " +
                     "WHERE m.recipient_id=? AND m.message_type IN ('PRIVATE','SYSTEM') " +
                     "ORDER BY m.sent_at DESC LIMIT ? OFFSET ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            p.setInt(2, limit);
            p.setInt(3, offset);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapMessage(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Message> getSentMessages(int userId, int offset, int limit) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, u.full_name as recipient_name " +
                     "FROM messages m " +
                     "LEFT JOIN users u ON u.id=m.recipient_id " +
                     "WHERE m.sender_id=? AND m.message_type IN ('PRIVATE','SYSTEM') " +
                     "ORDER BY m.sent_at DESC LIMIT ? OFFSET ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            p.setInt(2, limit);
            p.setInt(3, offset);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapMessage(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM messages WHERE recipient_id=? AND is_read=0 AND message_type IN ('PRIVATE','SYSTEM')";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean sendMessage(Message msg) {
        String sql = "INSERT INTO messages (sender_id, recipient_id, subject, body, message_type, priority, attachment_path) VALUES (?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, msg.getSenderId());
            p.setInt(2, msg.getRecipientId());
            p.setString(3, msg.getSubject());
            p.setString(4, msg.getBody());
            p.setString(5, msg.getMessageType());
            p.setString(6, msg.getPriority());
            p.setString(7, msg.getAttachmentPath());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) msg.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean markAsRead(int messageId, int userId) {
        String sql = "UPDATE messages SET is_read=1, read_at=NOW() WHERE id=? AND recipient_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, messageId);
            p.setInt(2, userId);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ========== Notifications ==========
    public List<Message> getNotifications(int userId, int offset, int limit) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT n.id, n.title as subject, n.body, n.type as priority, n.is_read as read, " +
                     "n.read_at, n.sent_at, n.action_url, n.reference_type, n.reference_id " +
                     "FROM notifications n WHERE n.user_id=? ORDER BY n.sent_at DESC LIMIT ? OFFSET ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            p.setInt(2, limit);
            p.setInt(3, offset);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Message n = new Message();
                    n.setId(r.getInt("id"));
                    n.setSubject(r.getString("subject"));
                    n.setBody(r.getString("body"));
                    n.setPriority(r.getString("priority"));
                    n.setRead(r.getInt("read") == 1);
                    n.setReadAt(r.getString("read_at"));
                    n.setSentAt(r.getString("sent_at"));
                    list.add(n);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int getUnreadNotificationCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean createNotification(int userId, String title, String body, String type, 
                                      String referenceType, int referenceId, String actionUrl) {
        String sql = "INSERT INTO notifications (user_id, title, body, type, reference_type, reference_id, action_url) VALUES (?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            p.setString(2, title);
            p.setString(3, body);
            p.setString(4, type);
            p.setString(5, referenceType);
            p.setInt(6, referenceId);
            p.setString(7, actionUrl);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean markNotificationRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read=1, read_at=NOW() WHERE id=? AND user_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, notificationId);
            p.setInt(2, userId);
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Message mapMessage(ResultSet r) throws SQLException {
        Message m = new Message();
        m.setId(r.getInt("id"));
        m.setSenderId(r.getInt("sender_id"));
        m.setSenderName(r.getString("sender_name"));
        m.setSenderRole(r.getString("sender_role"));
        m.setRecipientId(r.getInt("recipient_id"));
        m.setSubject(r.getString("subject"));
        m.setBody(r.getString("body"));
        m.setMessageType(r.getString("message_type"));
        m.setPriority(r.getString("priority"));
        m.setRead(r.getInt("is_read") == 1);
        m.setReadAt(r.getString("read_at"));
        m.setSentAt(r.getString("sent_at"));
        return m;
    }
}