# CollegeHub — Test Plan

## Overview

Comprehensive test strategy covering unit, integration, security, accessibility, and end-to-end testing.

---

## 1. Test Pyramid

```
        ┌─────────────┐
        │   E2E (5%)  │  Playwright: critical user journeys
        ├─────────────┤
        │Integration  │  Servlet + DAO + DB (Testcontainers)
        │  (20%)      │
        ├─────────────┤
        │   Unit (75%)│  DAO logic, utility classes, validators
        └─────────────┘
```

---

## 2. Unit Tests (JUnit 5 + Mockito)

### 2.1 DAO Layer Tests

| Class | Test Cases |
|-------|------------|
| **UserDAO** | authenticate(valid), authenticate(invalid), authenticate(locked), authenticate(legacy-upgrade), create, update, changePassword, setActive, delete(admin-blocked), delete(normal), getById, getByRole, searchByRole, searchByRolePaginated, emailOrUsernameExists, usernameExists, emailExists |
| **CourseDAO** | findAll, findByTeacher, findByStudent, findNotEnrolledByStudent, findById, create, update, delete, enroll, unenroll, countCourses |
| **AcademicDAO** | getEnrolledStudents, markAttendance, saveMark, getAttendanceSummary, getMarks, getCourseMarks, createNotice, deleteNotice, getNotices |

### 2.2 Utility Tests

| Class | Test Cases |
|-------|------------|
| **DBUtil** | hashPassword, verifyPassword, needsRehash, rehashIfNeeded, randomToken, randomCsrfToken, healthCheck, getPoolStats |
| **LoginRateLimiter** | isBlocked(new), isBlocked(expired), recordFailure, reset, remaining, concurrent access |

### 2.3 Model Tests

| Class | Test Cases |
|-------|------------|
| **User** | All getters/setters, active flag |
| **Course** | All getters/setters, nullable teacherId |
| **Notice** | All getters/setters |

---

## 3. Integration Tests (Testcontainers + MySQL)

### 3.1 Database Integration

- Schema migration (college_db.sql) applies cleanly
- FK constraints enforce referential integrity
- Unique constraints prevent duplicates
- CASCADE/SET NULL behaviors verified
- Indexes exist on FK columns

### 3.2 Servlet Integration

| Servlet | Test Scenarios |
|---------|----------------|
| **LoginServlet** | GET (redirect if authenticated), POST success, POST failure + rate limit, session fixation protection, role-based redirect |
| **LogoutServlet** | Session invalidation, redirect to login |
| **AdminServlet** | Dashboard, users (CRUD + search + pagination), courses (CRUD), notices (CRUD) |
| **TeacherServlet** | Dashboard, attendance (mark + export), marks (enter + export), notices |
| **StudentServlet** | Dashboard, courses (enroll/unenroll), attendance, marks, notices, profile (edit + password) |

### 3.3 Filter Chain Integration

| Filter | Test Scenarios |
|--------|----------------|
| **AuthFilter** | No session → redirect to login; wrong role → redirect to own dashboard; admin → access all; valid role → chain continues |
| **SecurityFilter** | Security headers present; CSRF token issued; POST without token → 403; POST with valid token → continues; GET no CSRF check |

---

## 4. Security Tests

### 4.1 Authentication & Authorization

| Test | Expected |
|------|----------|
| SQL injection in login | PreparedStatement prevents; no error leakage |
| SQL injection in search | LIKE escaping prevents injection |
| CSRF token missing on POST | 403 Forbidden |
| CSRF token invalid | 403 Forbidden |
| CSRF token valid | Request proceeds |
| Direct URL access /admin/* as student | Redirect to /student/dashboard |
| Direct URL access /teacher/* as admin | Allowed (admin superuser) |
| CSV export as student | 403 Forbidden |
| CSV export as teacher (other's course) | 403 Forbidden |
| CSV export as teacher (own course) | CSV downloaded |
| Session timeout | Redirect to login with message |

### 4.2 Password Security

| Test | Expected |
|------|----------|
| bcrypt cost factor | 12 (configurable) |
| Legacy SHA-256 upgrade | Upgraded on first successful login |
| Rehash on cost increase | Automatic rehash after login |
| Password min length | Enforced in UI (6 chars) + server |

### 4.3 Headers & CSP

| Header | Expected Value |
|--------|----------------|
| X-Content-Type-Options | nosniff |
| X-Frame-Options | DENY |
| Referrer-Policy | strict-origin-when-cross-origin |
| Content-Security-Policy | default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: |

### 4.4 Rate Limiting

| Scenario | Expected |
|----------|----------|
| 5 failed logins | Blocked for 10 minutes |
| 4 failed, wait 11 min | Allowed (window expired) |
| Concurrent attempts | Thread-safe (ConcurrentHashMap) |

---

## 5. Accessibility Tests (WCAG 2.2 AA)

### 5.1 Automated (axe-core)

Run against all JSP-rendered pages:
- Login page
- Admin dashboard, users, courses, notices
- Teacher dashboard, attendance, marks, notices
- Student dashboard, courses, attendance, marks, notices, profile

**Zero critical/major violations required.**

### 5.2 Manual Checklist

| Criterion | Pages to Verify |
|-----------|-----------------|
| Keyboard navigation | All pages |
| Focus visible | All interactive elements |
| Color contrast ≥4.5:1 | All text/UI (both themes) |
| Semantic HTML | All pages |
| ARIA labels | Icon buttons, live regions |
| Form labels | All inputs |
| Error identification | Login, forms |
| Reduced motion | All animations disabled |
| Touch targets ≥44px | Mobile view |

---

## 6. End-to-End Tests (Playwright)

### 6.1 Critical User Journeys

| Journey | Steps | Assertions |
|---------|-------|------------|
| **Admin creates teacher + course + notice** | Login admin → Users → Add Teacher → Courses → Add Course (assign teacher) → Notices → Post Notice | Teacher appears in list; course assigned; notice visible to teacher |
| **Teacher marks attendance + exports** | Login teacher → Dashboard → Attendance → Mark Present/Absent → Save → Export CSV | CSV downloads with correct data |
| **Teacher enters marks + exports** | Login teacher → Marks → Enter scores → Save → Export CSV | CSV downloads with percentages |
| **Student enrolls + views attendance/marks** | Login student → Courses → Enroll → Attendance → Marks | Enrolled course appears; attendance % shown; marks with grades |
| **Student profile + password change** | Login student → Profile → Edit → Save → Change Password | Profile updated; password changed; toasts shown |
| **Dark mode persistence** | Toggle theme → Reload → Theme retained | localStorage + data-theme match |
| **Mobile drawer** | Resize <900px → Hamburger → Open/Close → Navigate | Drawer toggles; navigation works |

### 6.2 Cross-Browser

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

---

## 7. Performance Tests

| Metric | Target | Tool |
|--------|--------|------|
| Login response (p95) | <500ms | JMeter/k6 |
| Dashboard load (p95) | <800ms | JMeter/k6 |
| CSV export (1000 rows) | <2s | JMeter/k6 |
| Concurrent users | 100 | JMeter/k6 |
| Connection pool exhaustion | Graceful degradation | JMeter/k6 |
| DB health check | <50ms | Unit test |

---

## 8. Test Data Management

### 8.1 Test Fixtures

```sql
-- Insert test users
INSERT INTO users (username, email, password_hash, salt, role, full_name) VALUES
('testadmin', 'admin@test.com', '$2a$12$...', 'bcrypt', 'ADMIN', 'Test Admin'),
('testteacher', 'teacher@test.com', '$2a$12$...', 'bcrypt', 'TEACHER', 'Test Teacher'),
('teststudent', 'student@test.com', '$2a$12$...', 'bcrypt', 'STUDENT', 'Test Student');

-- Insert test course
INSERT INTO courses (code, title, credits, semester, teacher_id) VALUES
('CS101', 'Intro to CS', 3, 1, 2);

-- Insert enrollment
INSERT INTO enrollments (student_id, course_id) VALUES (3, 1);
```

### 8.2 Test Database

- Use Testcontainers MySQL 8.x
- Schema applied per test class (`@BeforeAll`)
- Truncate tables per test method (`@BeforeEach`)
- Parallel test execution supported

---

## 9. CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: test
          MYSQL_DATABASE: college_db
        ports: ["3306:3306"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: 'temurin', java-version: '17' }
      - name: Build & Test
        run: mvn verify
      - name: Accessibility Audit
        run: python -m a11y_audit target/CollegeApp --ci
      - name: Security Scan
        run: mvn org.owasp:dependency-check-maven:check
```

---

## 10. Test Execution Commands

```bash
# Unit tests only
mvn test

# Integration tests (requires Testcontainers/Docker)
mvn verify -DskipITs=false

# All tests + reports
mvn clean verify

# Accessibility audit on built WAR
python -m a11y_audit target/CollegeApp --ci

# Security dependency check
mvn org.owasp:dependency-check-maven:check

# E2E tests (Playwright)
npx playwright test

# Load test
k6 run load-test.js
```

---

## 11. Coverage Targets

| Layer | Line Coverage | Branch Coverage |
|-------|---------------|-----------------|
| DAO | ≥90% | ≥85% |
| Util | ≥95% | ≥90% |
| Servlets | ≥80% | ≥75% |
| Overall | ≥85% | ≥80% |

---

## 12. Defect Tracking

| Severity | SLA | Examples |
|----------|-----|----------|
| Critical (P0) | Fix before release | Auth bypass, data loss, SQLi, XSS |
| Major (P1) | Fix within sprint | Broken feature, accessibility violation |
| Minor (P2) | Fix within 2 sprints | UI polish, performance, edge cases |

---

*This test plan is a living document — update with each sprint.*