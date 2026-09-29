package com.college.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.Instant;
import java.util.Base64;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Enhanced database utility with connection pooling, password hashing,
 * audit logging support, and secure random generation.
 */
public class DBUtil {
    private static final Logger log = LoggerFactory.getLogger(DBUtil.class);

    // Database configuration - externalize in production via environment variables
    // Default: root/system for Windows local development
    private static final String URL = System.getenv().getOrDefault("DB_URL",
        "jdbc:mysql://localhost:3306/college_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
    private static final String USER = System.getenv().getOrDefault("DB_USER", "root");
    private static final String PASS = System.getenv().getOrDefault("DB_PASS", "system");

    private static final HikariDataSource DS;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC driver not found: " + e.getMessage());
        }
        HikariConfig cfg = new HikariConfig();
        cfg.setJdbcUrl(URL);
        cfg.setUsername(USER);
        cfg.setPassword(PASS);
        cfg.setMaximumPoolSize(20);
        cfg.setMinimumIdle(5);
        cfg.setPoolName("CollegeHub-Pool");
        cfg.setConnectionTimeout(10_000);
        cfg.setIdleTimeout(300_000);
        cfg.setMaxLifetime(600_000);
        cfg.setLeakDetectionThreshold(60_000);
        cfg.addDataSourceProperty("cachePrepStmts", "true");
        cfg.addDataSourceProperty("prepStmtCacheSize", "250");
        cfg.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        cfg.addDataSourceProperty("useServerPrepStmts", "true");
        DS = new HikariDataSource(cfg);
        log.info("HikariCP connection pool initialized: {}", DS.getPoolName());
    }

    /** Borrow a pooled connection (auto-returns on close via try-with-resources). */
    public static Connection getConnection() throws SQLException {
        return DS.getConnection();
    }

    /** Graceful shutdown hook for application context destruction. */
    public static void shutdown() {
        if (DS != null && !DS.isClosed()) {
            DS.close();
            log.info("HikariCP connection pool shut down");
        }
    }

    // ==================== Password Hashing ====================

    /** bcrypt cost factor (adjust for security/performance balance). */
    private static final int BCRYPT_COST = 12;

    /**
     * Hash a password using bcrypt with the configured cost factor.
     * @param password plain-text password
     * @return bcrypt hash (includes salt and cost)
     */
    public static String hashPassword(String password) {
        return org.mindrot.jbcrypt.BCrypt.hashpw(password, org.mindrot.jbcrypt.BCrypt.gensalt(BCRYPT_COST));
    }

    /**
     * Verify a plain-text password against a bcrypt hash.
     * @param password plain-text password
     * @param hash stored bcrypt hash
     * @return true if match
     */
    public static boolean verifyPassword(String password, String hash) {
        if (hash == null || !hash.startsWith("$2")) {
            return false; // not a bcrypt hash
        }
        try {
            return org.mindrot.jbcrypt.BCrypt.checkpw(password, hash);
        } catch (IllegalArgumentException e) {
            log.warn("Invalid bcrypt hash format during verification");
            return false;
        }
    }

    /**
     * Check if a hash needs rehashing (e.g., cost factor increased).
     * @param hash stored bcrypt hash
     * @return true if rehash recommended
     */
    public static boolean needsRehash(String hash) {
        if (hash == null || !hash.startsWith("$2")) return true;
        try {
            // Extract cost from hash: $2a$12$...
            int cost = Integer.parseInt(hash.substring(4, 6));
            return cost < BCRYPT_COST;
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * Rehash password if needed (call after successful login).
     * @param password plain-text password
     * @param currentHash current stored hash
     * @return new hash if rehashed, otherwise current hash
     */
    public static String rehashIfNeeded(String password, String currentHash) {
        if (needsRehash(currentHash)) {
            log.info("Rehashing password with increased cost factor");
            return hashPassword(password);
        }
        return currentHash;
    }

    /** Legacy SHA-256 hash (kept for the seeded admin account migration). */
    @Deprecated
    public static String sha256(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes());
            byte[] bytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // ==================== Secure Random Generation ====================

    /** Generate a cryptographically secure random token (URL-safe base64). */
    public static String randomToken(int bytes) {
        byte[] buf = new byte[bytes];
        SECURE_RANDOM.nextBytes(buf);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(buf);
    }

    /** Generate a secure random salt (legacy compatibility). */
    @Deprecated
    public static String randomSalt() {
        return randomToken(24);
    }

    /** Generate a secure session ID. */
    public static String randomSessionId() {
        return randomToken(32);
    }

    /** Generate a CSRF token. */
    public static String randomCsrfToken() {
        return randomToken(32);
    }

    // ==================== Audit Logging Helpers ====================

    /**
     * Record an audit event (to be stored in audit_log table when implemented).
     * Currently logs to SLF4J; replace with DB insert when audit table exists.
     */
    public static void audit(String action, String entityType, Integer entityId, Integer actorId, String details) {
        log.info("AUDIT: action={} entityType={} entityId={} actorId={} details={} timestamp={}",
            action, entityType, entityId, actorId, details, Instant.now().toString());
    }

    public static void auditLogin(String username, boolean success, String ip, String userAgent) {
        log.info("AUDIT_LOGIN: username={} success={} ip={} userAgent={} timestamp={}",
            username, success, ip, userAgent, Instant.now().toString());
    }

    public static void auditDataChange(String table, String operation, Integer recordId, Integer actorId, String oldValues, String newValues) {
        log.info("AUDIT_DATA: table={} operation={} recordId={} actorId={} old={} new={} timestamp={}",
            table, operation, recordId, actorId, oldValues, newValues, Instant.now().toString());
    }

    // ==================== Health Check ====================

    /** Test database connectivity. */
    public static boolean healthCheck() {
        try (Connection c = getConnection()) {
            return c.isValid(2);
        } catch (SQLException e) {
            log.error("Database health check failed", e);
            return false;
        }
    }

    /** Get pool statistics for monitoring. */
    public static PoolStats getPoolStats() {
        return new PoolStats(
            DS.getHikariPoolMXBean().getActiveConnections(),
            DS.getHikariPoolMXBean().getIdleConnections(),
            DS.getHikariPoolMXBean().getTotalConnections(),
            DS.getHikariPoolMXBean().getThreadsAwaitingConnection()
        );
    }

    public static class PoolStats {
        public final int active;
        public final int idle;
        public final int total;
        public final int waiting;

        public PoolStats(int active, int idle, int total, int waiting) {
            this.active = active;
            this.idle = idle;
            this.total = total;
            this.waiting = waiting;
        }
    }
}