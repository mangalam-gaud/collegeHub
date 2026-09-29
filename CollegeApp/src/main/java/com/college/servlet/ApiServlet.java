package com.college.servlet;

import com.college.util.DBUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/api/*")
public class ApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // Simple API key check (in production, use proper JWT/OAuth)
        String apiKey = req.getHeader("X-API-Key");
        if (apiKey == null || !apiKey.equals(System.getenv().getOrDefault("API_KEY", "dev-key-123"))) {
            resp.setStatus(401);
            writeJson(resp, "{\"error\":\"Unauthorized\",\"message\":\"Valid X-API-Key header required\"}");
            return;
        }

        try {
            switch (path != null ? path : "") {
                case "/stats":
                    handleStats(resp);
                    break;
                case "/users":
                    handleUsers(req, resp);
                    break;
                case "/courses":
                    handleCourses(resp);
                    break;
                case "/health":
                    handleHealth(resp);
                    break;
                default:
                    resp.setStatus(404);
                    writeJson(resp, "{\"error\":\"Not Found\",\"path\":\"" + path + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            writeJson(resp, "{\"error\":\"Internal Server Error\",\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    private void handleStats(HttpServletResponse resp) throws Exception {
        try (Connection c = DBUtil.getConnection()) {
            int students = count(c, "SELECT COUNT(*) FROM users WHERE role='STUDENT'");
            int teachers = count(c, "SELECT COUNT(*) FROM users WHERE role='TEACHER'");
            int admins = count(c, "SELECT COUNT(*) FROM users WHERE role='ADMIN'");
            int courses = count(c, "SELECT COUNT(*) FROM courses");
            int enrollments = count(c, "SELECT COUNT(*) FROM enrollments");
            int notices = count(c, "SELECT COUNT(*) FROM notices");

            writeJson(resp, String.format(
                "{\"students\":%d,\"teachers\":%d,\"admins\":%d,\"courses\":%d,\"enrollments\":%d,\"notices\":%d}",
                students, teachers, admins, courses, enrollments, notices
            ));
        }
    }

    private void handleUsers(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String role = req.getParameter("role");
        String q = req.getParameter("q");
        int page = parseInt(req.getParameter("page"), 1);
        int size = Math.min(parseInt(req.getParameter("size"), 20), 100);

        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1");
        if (role != null && !role.isBlank()) sql.append(" AND role=?");
        if (q != null && !q.isBlank()) {
            String like = "%" + q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
            sql.append(" AND (full_name LIKE ? ESCAPE '\\\\' OR username LIKE ? ESCAPE '\\\\' OR email LIKE ? ESCAPE '\\\\')");
        }
        sql.append(" ORDER BY full_name LIMIT ? OFFSET ?");

        try (Connection c = DBUtil.getConnection(); PreparedStatement p = c.prepareStatement(sql.toString())) {
            int idx = 1;
            if (role != null && !role.isBlank()) p.setString(idx++, role);
            if (q != null && !q.isBlank()) {
                String like = "%" + q.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
                p.setString(idx++, like);
                p.setString(idx++, like);
                p.setString(idx++, like);
            }
            p.setInt(idx++, size);
            p.setInt(idx++, (page - 1) * size);

            try (ResultSet r = p.executeQuery()) {
                StringBuilder json = new StringBuilder("{\"users\":[");
                boolean first = true;
                while (r.next()) {
                    if (!first) json.append(",");
                    json.append(userToJson(r));
                    first = false;
                }
                json.append("],\"page\":").append(page).append(",\"size\":").append(size).append("}");
                writeJson(resp, json.toString());
            }
        }
    }

    private void handleCourses(HttpServletResponse resp) throws Exception {
        String sql = "SELECT c.*, u.full_name AS teacher_name FROM courses c LEFT JOIN users u ON c.teacher_id=u.id ORDER BY c.code";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            StringBuilder json = new StringBuilder("{\"courses\":[");
            boolean first = true;
            while (r.next()) {
                if (!first) json.append(",");
                json.append(courseToJson(r));
                first = false;
            }
            json.append("]}");
            writeJson(resp, json.toString());
        }
    }

    private void handleHealth(HttpServletResponse resp) throws Exception {
        boolean dbHealthy = DBUtil.healthCheck();
        DBUtil.PoolStats pool = DBUtil.getPoolStats();

        writeJson(resp, String.format(
            "{\"status\":\"%s\",\"database\":{\"connected\":%b,\"pool\":{\"active\":%d,\"idle\":%d,\"total\":%d,\"waiting\":%d}},%n",
            dbHealthy ? "UP" : "DOWN", dbHealthy, pool.active, pool.idle, pool.total, pool.waiting
        ) + "\"timestamp\":\"" + java.time.Instant.now() + "\"}");
    }

    private int count(Connection c, String sql) throws Exception {
        try (Statement s = c.createStatement(); ResultSet r = s.executeQuery(sql)) {
            return r.next() ? r.getInt(1) : 0;
        }
    }

    private String userToJson(ResultSet r) throws Exception {
        return String.format(
            "{\"id\":%d,\"username\":\"%s\",\"email\":\"%s\",\"role\":\"%s\",\"fullName\":\"%s\",\"phone\":\"%s\",\"gender\":\"%s\",\"dob\":\"%s\",\"address\":\"%s\",\"active\":%b}",
            r.getInt("id"),
            escape(r.getString("username")),
            escape(r.getString("email")),
            escape(r.getString("role")),
            escape(r.getString("full_name")),
            escape(r.getString("phone")),
            escape(r.getString("gender")),
            escape(r.getString("dob")),
            escape(r.getString("address")),
            r.getInt("active") == 1
        );
    }

    private String courseToJson(ResultSet r) throws Exception {
        return String.format(
            "{\"id\":%d,\"code\":\"%s\",\"title\":\"%s\",\"credits\":%d,\"semester\":%d,\"teacherId\":%s,\"teacherName\":\"%s\"}",
            r.getInt("id"),
            escape(r.getString("code")),
            escape(r.getString("title")),
            r.getInt("credits"),
            r.getInt("semester"),
            r.getObject("teacher_id") != null ? r.getInt("teacher_id") : "null",
            escape(r.getString("teacher_name"))
        );
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.getWriter().write(json);
    }
}