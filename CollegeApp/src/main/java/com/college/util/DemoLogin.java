package com.college.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Single source of truth for the demo accounts created by
 * {@code database/seed_demo_data.sql}.
 *
 * The login screen renders one-tap sign-in tiles from this list, so the
 * credentials shown to a user can never drift away from what the seed script
 * actually inserts. The passwords here are the demo-only plaintext values; the
 * database stores real bcrypt hashes (cost 12) and authentication still runs
 * through the normal {@code UserDAO.authenticate} path.
 *
 * DemoLogin is only wired into the UI behind {@link #isEnabled()}, which is
 * driven by the {@code college.demo.login} system property (default: on for
 * local development, off when the property is explicitly set to false).
 * Deployments should set {@code -Dcollege.demo.login=false} to hide it.
 */
public final class DemoLogin {

    /** One demo account. */
    public static final class Account {
        public final String username;
        public final String password;
        public final String role;
        public final String label;
        public final String landingPage;
        public final String icon;

        Account(String username, String password, String role, String label,
                String landingPage, String icon) {
            this.username = username;
            this.password = password;
            this.role = role;
            this.label = label;
            this.landingPage = landingPage;
            this.icon = icon;
        }
    }

    /** role -> accounts, in display order. */
    private static final Map<String, List<Account>> BY_ROLE = new LinkedHashMap<>();

    static {
        BY_ROLE.put("ADMIN", list(
            new Account("admin", "Admin@123", "ADMIN", "Administrator", "admin/dashboard", "🛡️"),
            new Account("viceprincipal", "Vice@123", "ADMIN", "Vice Principal", "admin/dashboard", "🎖️")
        ));
        BY_ROLE.put("ACADEMIC", list(
            new Account("teacher1", "Teacher@123", "TEACHER", "Teacher — CSE", "teacher/dashboard", "📐"),
            new Account("teacher2", "Teacher@123", "TEACHER", "Teacher — BSH", "teacher/dashboard", "📐"),
            new Account("teacher3", "Teacher@123", "TEACHER", "Teacher — ECE", "teacher/dashboard", "📐"),
            new Account("teacher4", "Teacher@123", "TEACHER", "Teacher — ME", "teacher/dashboard", "📐")
        ));
        BY_ROLE.put("STUDENT", list(
            new Account("student1", "Student@123", "STUDENT", "Student — Hostel", "student/dashboard", "🎓"),
            new Account("student2", "Student@123", "STUDENT", "Student — OBC", "student/dashboard", "🎓"),
            new Account("student3", "Student@123", "STUDENT", "Student — Transport", "student/dashboard", "🎓"),
            new Account("student4", "Student@123", "STUDENT", "Student — SC", "student/dashboard", "🎓"),
            new Account("student5", "Student@123", "STUDENT", "Student — Day Scholar", "student/dashboard", "🎓"),
            new Account("student6", "Student@123", "STUDENT", "Student — EWS", "student/dashboard", "🎓"),
            new Account("student7", "Student@123", "STUDENT", "Student — Route R-03", "student/dashboard", "🎓"),
            new Account("student8", "Student@123", "STUDENT", "Student — OBC", "student/dashboard", "🎓")
        ));
        BY_ROLE.put("STAFF", list(
            new Account("accountant", "Accounts@123", "ACCOUNTANT", "Accountant — Fees", "fee/dashboard", "💰"),
            new Account("librarian", "Library@123", "LIBRARIAN", "Librarian", "library/dashboard", "📚"),
            new Account("warden", "Warden@123", "HOSTEL_WARDEN", "Hostel Warden", "hostel/dashboard", "🏠"),
            new Account("transport", "Transport@123", "TRANSPORT_MANAGER", "Transport Manager", "transport/dashboard", "🚌")
        ));
        BY_ROLE.put("PARENT", list(
            new Account("parent1", "Parent@123", "PARENT", "Parent", "student/dashboard", "👨‍👩‍👧")
        ));
    }

    private static List<Account> list(Account... a) {
        List<Account> l = new ArrayList<>();
        Collections.addAll(l, a);
        return Collections.unmodifiableList(l);
    }

    private DemoLogin() {
    }

    /**
     * Demo sign-in is shown unless explicitly disabled.
     *
     * @return true when the login screen should render the demo tiles
     */
    public static boolean isEnabled() {
        return !"false".equalsIgnoreCase(
            System.getProperty("college.demo.login",
                System.getenv().getOrDefault("COLLEGE_DEMO_LOGIN", "true")));
    }

    /** Group labels in display order. */
    public static List<String> groups() {
        return new ArrayList<>(BY_ROLE.keySet());
    }

    /** Accounts within a group, in display order. */
    public static List<Account> accountsIn(String group) {
        List<Account> l = BY_ROLE.get(group);
        return l == null ? Collections.<Account>emptyList() : l;
    }

    /** Every demo account, flattened. */
    public static List<Account> all() {
        List<Account> out = new ArrayList<>();
        for (List<Account> l : BY_ROLE.values()) out.addAll(l);
        return out;
    }

    /** True when the username is one of the demo accounts. */
    public static boolean isDemoUser(String username) {
        if (username == null) return false;
        for (Account a : all()) {
            if (a.username.equalsIgnoreCase(username)) return true;
        }
        return false;
    }
}
