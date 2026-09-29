# CollegeHub — Comprehensive Architecture Document

## Executive Summary

This document describes the complete architecture for **CollegeHub**, a production-grade college management system built on **Java 17+, Jakarta EE 10 (Servlet 6.0), JSP/JSTL, MySQL 8**, with **HikariCP connection pooling**, **jBCrypt password hashing**, and a **zero-dependency vanilla JS frontend** implementing a full design system with dark/light mode, accessibility (WCAG 2.2 AA), and modern UX patterns.

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Admin     │  │  Teacher    │  │  Student    │  │   Public    │        │
│  │   Portal    │  │  Portal     │  │  Portal     │  │   Login     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │               │
│         └────────────────┼────────────────┼────────────────┘               │
│                          ▼                                                │
│              ┌─────────────────────────┐                                 │
│              │   JSP View Layer        │                                 │
│              │   (Layouts + Partials)  │                                 │
│              │   + Vanilla JS (app.js) │                                 │
│              └───────────┬─────────────┘                                 │
└──────────────────────────┼────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CONTROLLER LAYER (Servlets)                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Login      │  │  Admin      │  │  Teacher    │  │  Student    │        │
│  │  Servlet    │  │  Servlet    │  │  Servlet    │  │  Servlet    │        │
│  └─────────────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │               │
│         └────────────────┼────────────────┼────────────────┘               │
│                          ▼                                                │
│              ┌─────────────────────────┐                                 │
│              │   Filter Chain          │                                 │
│              │   AuthFilter (RBAC)     │                                 │
│              │   SecurityFilter (CSRF, │                                 │
│              │   Headers, CSP)         │                                 │
│              └───────────┬─────────────┘                                 │
└──────────────────────────┼────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SERVICE LAYER (DAOs)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │
│  │  UserDAO    │  │  CourseDAO  │  │ AcademicDAO │                         │
│  └─────────────┘  └─────────────┘  └─────────────┘                         │
└──────────────────────────┼────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA ACCESS LAYER                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DBUtil (HikariCP Pool)                            │   │
│  │         Connection Pool + SHA-256 + bcrypt + Random Salt             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────┼────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATABASE (MySQL 8+)                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  users • departments • courses • enrollments • attendance • marks  │   │
│  │  • notices                                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. MVC Layer Responsibilities

### 2.1 Model Layer (POJOs + DAOs)

| Class | Responsibility | Key Methods |
|-------|---------------|-------------|
| **User** | Domain model for users (Admin/Teacher/Student) | getters/setters for id, username, email, role, fullName, phone, gender, dob, address, active |
| **Course** | Domain model for courses | getters/setters for id, code, title, credits, semester, departmentId, teacherId, teacherName |
| **Notice** | Domain model for announcements | getters/setters for id, title, body, authorName, audience, createdAt |
| **UserDAO** | User persistence + authentication + bcrypt upgrade | authenticate(), create(), update(), changePassword(), setActive(), delete(), getById(), getByRole(), searchByRole(), countByRole(), emailOrUsernameExists() |
| **CourseDAO** | Course CRUD + enrollment management | findAll(), findByTeacher(), findByStudent(), findNotEnrolledByStudent(), findById(), create(), update(), delete(), enroll(), unenroll(), countCourses() |
| **AcademicDAO** | Attendance, marks, notices (academic operations) | getEnrolledStudents(), markAttendance(), saveMark(), getAttendanceSummary(), getMarks(), getCourseMarks(), createNotice(), deleteNotice(), getNotices() |

### 2.2 View Layer (JSP + CSS + Vanilla JS)

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **layout/top.jsp** | Shell header + sidebar + CSRF token injection | Role-based navigation, theme toggle, user avatar, clock, hamburger menu |
| **layout/bottom.jsp** | Shell footer + JS bundle | Loads `app.js` deferred |
| **login.jsp** | Public authentication page | Animated mesh background, password toggle, inline validation, CSRF |
| **admin/*.jsp** | Admin portal views | Dashboard stats, user management (search, sort, filter, CRUD), course management, notices |
| **teacher/*.jsp** | Teacher portal views | My courses, attendance marking, marks entry, CSV export, notices |
| **student/*.jsp** | Student portal views | Dashboard (stats cards), courses (enroll/unenroll), attendance, marks, notices, profile |
| **css/style.css** | Complete design system | CSS custom properties (light/dark), animations, responsive grid, components, utilities |
| **js/app.js** | Reactive interaction layer | Theme persistence, loading bar, toasts, table sorting/filtering, count-up animations, progress bars, skeletons, mobile drawer, keyboard shortcuts |

### 2.3 Controller Layer (Servlets + Filters)

| Servlet/Filter | URL Pattern | Responsibility |
|----------------|-------------|----------------|
| **AuthFilter** | `/admin/*`, `/teacher/*`, `/student/*` | RBAC enforcement: validates session + role match; redirects to login or role-appropriate dashboard |
| **SecurityFilter** | `/*` (all requests) | Security headers (CSP, X-Frame-Options, nosniff), CSRF token issuance/validation on POST |
| **LoginServlet** | `/login` | GET: show login (redirect if authenticated); POST: authenticate + rate limit + session fixation protection + role-based redirect |
| **LogoutServlet** | `/logout` | Invalidate session, redirect to login |
| **AdminServlet** | `/admin/*` | Dashboard, users (CRUD + search), courses (CRUD), notices (CRUD) |
| **TeacherServlet** | `/teacher/*` | Dashboard, my courses, attendance (mark + CSV export), marks (enter + CSV export), notices |
| **StudentServlet** | `/student/*` | Dashboard, courses (enroll/unenroll), attendance (view), marks (view), notices, profile (edit + password change) |

---

## 3. RBAC Architecture

### 3.1 Role Hierarchy

```
ADMIN (superuser)
  ├── Can access ALL endpoints
  ├── User management (CRUD students/teachers)
  ├── Course management (CRUD + teacher assignment)
  ├── Notices (all audiences)
  └── System configuration

TEACHER
  ├── Dashboard (own courses + notices)
  ├── My Courses (assigned only)
  ├── Attendance (mark + export CSV for own courses)
  ├── Marks (enter + export CSV for own courses)
  ├── Notices (post to STUDENT or ALL)
  └── Profile (view only)

STUDENT
  ├── Dashboard (enrolled courses + stats + notices)
  ├── Courses (enroll/unenroll from available)
  ├── Attendance (view own summary with %)
  ├── Marks (view own with grade calculation)
  ├── Notices (view STUDENT + ALL)
  └── Profile (edit + password change)
```

### 3.2 Permission Matrix

| Resource | ADMIN | TEACHER | STUDENT |
|----------|-------|---------|---------|
| `/admin/**` | ✅ Full | ❌ | ❌ |
| `/teacher/**` | ✅ Full | ✅ Own | ❌ |
| `/student/**` | ✅ Full | ❌ | ✅ Own |
| User CRUD | ✅ | ❌ | ❌ (self profile only) |
| Course CRUD | ✅ | ❌ (view assigned) | ❌ (enroll only) |
| Attendance Write | ✅ | ✅ (own courses) | ❌ |
| Marks Write | ✅ | ✅ (own courses) | ❌ |
| Notices Write | ✅ (all audiences) | ✅ (STUDENT/ALL) | ❌ |
| CSV Export | ✅ | ✅ (own courses) | ❌ |

### 3.3 Implementation Details

**AuthFilter** (`com.college.filter.AuthFilter`):
- Extracts `User` from session
- Determines required role from request URI (`/admin/` → ADMIN, `/teacher/` → TEACHER, else STUDENT)
- Allows ADMIN to access everything
- Redirects mismatched roles to their correct dashboard

**SecurityFilter** (`com.college.filter.SecurityFilter`):
- `@WebFilter("/*")` — runs on every request
- Sets security headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, `Content-Security-Policy`
- Issues CSRF token per session (`UUID.randomUUID()`)
- Validates CSRF token on all POST requests (form field `csrf`)

**LoginServlet** rate limiting:
- `LoginRateLimiter`: 5 failed attempts per username per 10 minutes (in-memory `ConcurrentHashMap`)
- On success: invalidates old session, creates new session, sets `user` attribute, 30-min timeout

---

## 4. Database Schema

```sql
-- Core tables (from database/college_db.sql)
users          (id, username, email, password_hash, salt, role, full_name, phone, gender, dob, address, active, created_at)
departments    (id, name, hod)
courses        (id, code, title, credits, semester, department_id, teacher_id)
enrollments    (id, student_id, course_id, enrolled_at) -- unique(student_id, course_id)
attendance     (id, student_id, course_id, att_date, status, marked_by) -- unique(student_id, course_id, att_date)
marks          (id, student_id, course_id, exam_type, marks_obtained, max_marks, entered_by) -- unique(student_id, course_id, exam_type)
notices        (id, title, body, posted_by, audience, created_at)
```

**Indexes & Constraints:**
- PK on all `id` columns (auto-increment)
- UNIQUE on `users.username`, `users.email`, `courses.code`
- FK: `courses.department_id → departments.id` (SET NULL), `courses.teacher_id → users.id` (SET NULL)
- FK: `enrollments.student_id → users.id` (CASCADE), `enrollments.course_id → courses.id` (CASCADE)
- FK: `attendance.student_id → users.id` (CASCADE), `attendance.course_id → courses.id` (CASCADE)
- FK: `marks.student_id → users.id` (CASCADE), `marks.course_id → courses.id` (CASCADE)
- FK: `notices.posted_by → users.id` (CASCADE)

---

## 5. Security Hardening

| Measure | Implementation |
|---------|----------------|
| **Password Hashing** | bcrypt (cost factor 10) for all new accounts; legacy SHA-256 admin transparently upgraded on first login |
| **Connection Pool** | HikariCP: 10 max, 2 min-idle, 10s connection timeout, pool name "CollegeHub-Pool" |
| **CSRF Protection** | Per-session token in `SecurityFilter`; validated on all POST; injected via `${csrfField}` in JSPs |
| **Security Headers** | CSP: `default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:`; X-Frame-Options: DENY; nosniff; Referrer-Policy |
| **Rate Limiting** | LoginRateLimiter: 5 failures/10min per username (in-memory) |
| **Session Fixation** | New session created after successful login; old session invalidated |
| **Authorization Checks** | CSV export validates teacher owns course (or admin) |
| **SQL Injection Prevention** | All queries use `PreparedStatement` with parameter binding |
| **XSS Prevention** | JSTL `<c:out>` / `${fn:escapeXml()}` in JSPs; CSP restricts inline scripts |

---

## 6. Design System (Frontend)

### 6.1 Token Architecture (CSS Custom Properties)

**Primitive Layer** (raw values):
```css
--primary-500: #6366f1; --green-500: #22c55e; --red-500: #ef4444;
--gray-50: #f7f6f2; --gray-900: #151827; --font: "SF Pro Text", ...;
--radius: 12px; --sidebar-w: 250px; --topbar-h: 64px;
```

**Semantic Layer** (purpose aliases):
```css
--ink: #1a1d2b; --paper: var(--gray-50); --card: #ffffff; --line: var(--gray-200);
--shadow: 0 6px 20px -8px rgba(21,24,39,.14);
```

**Dark Mode** via `[data-theme="dark"]` override (all tokens redefined).

### 6.2 Component Library

| Component | Variants | States |
|-----------|----------|--------|
| **Button** | primary, outline, danger, sm | hover, active, disabled, busy (spinner), ripple |
| **Card** | default, hover lift | shadow transitions |
| **Stat Card** | numeric with prefix/suffix | count-up animation, progress ring |
| **Table** | sortable headers, hover rows, sticky th | hit/dim classes for filtering |
| **Badge** | admin, teacher, student, on/off, present/absent | theme-aware colors |
| **Form Fields** | input, select, textarea, radio pills | focus ring, hover border, validation states |
| **Alert** | error, success | slide-in animation |
| **Notice** | bordered left accent | hover translateX + shadow |
| **Toast** | success, error | stack, auto-dismiss, manual close |
| **Progress Bar** | top loading bar | animated gradient |
| **Skeleton** | shimmer placeholder | CSS animation |

### 6.3 Responsive Breakpoints

| Breakpoint | Behavior |
|------------|----------|
| `≤960px` | Grid layouts collapse to 1 column |
| `≤900px` | Sidebar becomes off-canvas drawer (hamburger toggle); brand text hidden in collapsed state |

### 6.4 Motion & Accessibility

- `@media (prefers-reduced-motion: reduce)` disables all animations
- Focus-visible outlines on all interactive elements
- Semantic HTML: `<nav>`, `<main>`, `<aside>`, `<button>`, `<a>`
- ARIA labels on icon buttons, live regions for toasts/clock
- Color contrast ≥4.5:1 (validated via design tokens)

---

## 7. Frontend Interaction Layer (`app.js`)

| Feature | Implementation |
|---------|----------------|
| **Theme** | `localStorage` + `matchMedia` prefers-color-scheme; toggles `[data-theme]` on `<html>` |
| **Loading Bar** | Top 3px animated gradient; shows on `beforeunload` + form submit |
| **Toasts** | Stack at bottom-right; auto-dismiss 4.2s; maps URL params (`?saved=1`, `?pwchanged=1`) to toast messages |
| **Table Sort** | Click `th[data-sort]`; numeric + locale-aware string sort; toggles ▲/▼ |
| **Live Filter** | `[data-filter]` input filters table rows in real-time; shows hit count badge |
| **Count-Up** | `.stat .num` animates 0→value in 750ms (cubic-bezier) |
| **Progress Bars** | Synthesized from `[data-pct]` on table cells; color-coded (good/low) |
| **Skeleton→Reveal** | `.stat`, `.card`, `.table-wrap` get staggered fade-in-up animation |
| **Mobile Drawer** | Body class `nav-open`; ESC closes; click outside closes |
| **Keyboard Shortcuts** | `/` focuses search; `Esc` closes drawer |
| **Button Ripple** | Material-style ripple on click (non-danger buttons) |
| **Clock** | Live date/time in topbar (locale-aware, updates every second) |

---

## 8. Build & Deployment

### 8.1 Maven Configuration (`pom.xml`)

- **Packaging**: `war`
- **Java**: 11 (source/target)
- **Dependencies** (provided/runtime):
  - `jakarta.servlet-api:6.0.0` (provided)
  - `mysql-connector-j:8.4.0`
  - `HikariCP:5.1.0`
  - `slf4j-simple:2.0.13`
  - `jbcrypt:0.4`
  - `jakarta.servlet.jsp.jstl:3.0.1` + API
- **Plugin**: `maven-war-plugin:3.4.0` → `target/CollegeApp.war`

### 8.2 Deployment Steps

1. **Database**: `mysql -u root -p < database/college_db.sql`
2. **Configure DB**: Edit `DBUtil.java` (USER/PASS/URL)
3. **Build**: `mvn clean package`
4. **Deploy**: Copy `target/CollegeApp.war` to Tomcat 10.1+ `webapps/`
5. **Access**: `http://localhost:8080/CollegeApp/`

---

## 9. Quality Gates & CI/CD Readiness

| Gate | Tool/Method |
|------|-------------|
| **Compile** | `mvn compile` |
| **Package** | `mvn package` (produces WAR) |
| **Security Scan** | `security-guidance` hook (pre-write), dependency check (OWASP) |
| **Accessibility** | `a11y-audit` scanner on JSP/HTML output |
| **Code Quality** | `senior-fullstack` analyzer (complexity, security, deps) |
| **Architecture Review** | `senior-architect` project assessment |

---

## 10. Extensibility Points

| Extension | Location | Pattern |
|-----------|----------|---------|
| New Role | `users.role` enum + `AuthFilter` + servlet mapping | Add role constant, update filter logic, create servlet |
| New Resource | DAO + Servlet + JSP + web.xml filter mapping | Follow existing DAO/Servlet/JSP conventions |
| New Academic Feature | `AcademicDAO` + Teacher/Student servlet actions + JSPs | Add DAO methods, wire in servlets, create views |
| API Endpoints | New servlet with `@WebServlet("/api/*")` + JSON response | Use `jakarta.json` or Jackson (add dependency) |
| External Auth | Replace `UserDAO.authenticate()` | Implement `AuthenticationProvider` interface |
| Multi-tenancy | Add `tenant_id` to all tables + filter | ThreadLocal tenant context + query scoping |

---

## 11. Monitoring & Observability (Future)

| Concern | Recommended Addition |
|---------|---------------------|
| **Logging** | SLF4J → Logback with JSON layout; MDC for requestId/userId |
| **Metrics** | Micrometer + Prometheus endpoint (`/actuator/prometheus`) |
| **Tracing** | OpenTelemetry Java agent |
| **Health Checks** | Spring Boot Actuator style `/health` endpoint |
| **Error Tracking** | Sentry / Rollbar integration |

---

## 12. Decision Log (ADRs)

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| 001 | Use Jakarta EE 10 (Servlet 6) over Spring Boot | Accepted | 2024 |
| 002 | Server-side rendering (JSP) over SPA | Accepted | 2024 |
| 003 | bcrypt for passwords with legacy SHA-256 upgrade path | Accepted | 2024 |
| 004 | In-memory rate limiting (no Redis) for simplicity | Accepted | 2024 |
| 005 | Vanilla JS + CSS custom properties (no build step) | Accepted | 2024 |
| 006 | HikariCP for connection pooling | Accepted | 2024 |
| 007 | CSRF token per session (not per request) | Accepted | 2024 |

---

*Generated from codebase analysis — reflects actual implementation as of current commit.*