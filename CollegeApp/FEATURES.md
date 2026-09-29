# CollegeHub — Feature Specification

## Overview

Complete feature inventory for CollegeHub, organized by role and domain. Each feature includes acceptance criteria, technical notes, and security considerations.

---

## 1. Authentication & Session Management

| ID | Feature | Description | Acceptance Criteria |
|----|---------|-------------|---------------------|
| AUTH-01 | User Login | Username/password authentication with bcrypt verification | ✅ Valid credentials → role-based redirect; ❌ Invalid → error + rate limit |
| AUTH-02 | Rate Limiting | 5 failed attempts per username per 10 minutes | Blocked users see "Try again in a few minutes"; counter resets on success |
| AUTH-03 | Session Fixation Protection | New session ID issued after successful login | Old session invalidated; new session with 30-min timeout |
| AUTH-04 | Session Timeout | 30-minute sliding expiration | Inactive users redirected to login with "Session expired" |
| AUTH-05 | Logout | Explicit session invalidation | POST `/logout` invalidates session, redirects to login |
| AUTH-06 | Remember Me (Future) | Persistent login token | Secure HTTP-only cookie; rotating token; revocable |

---

## 2. RBAC & Authorization

| ID | Feature | Description | Acceptance Criteria |
|----|---------|-------------|---------------------|
| RBAC-01 | Role-Based Access Control | Three roles: ADMIN, TEACHER, STUDENT | AuthFilter enforces on `/admin/*`, `/teacher/*`, `/student/*` |
| RBAC-02 | Admin Superuser | Admin bypasses all role checks | Admin can access teacher/student endpoints |
| RBAC-03 | Teacher Course Scoping | Teachers only see/manage assigned courses | CourseDAO.findByTeacher(); export validates ownership |
| RBAC-04 | Student Self-Service | Students only access own data | Enrollment, attendance, marks, profile scoped to user ID |
| RBAC-05 | URL-Level Protection | Direct URL access blocked for unauthorized roles | Redirect to correct dashboard with flash message |

---

## 3. Admin Portal

### 3.1 Dashboard
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| ADM-01 | Stats Cards | Student count, Teacher count, Course count, Recent notices (4) |
| ADM-02 | Quick Actions | Buttons: Add Student, Add Teacher, Add Course, Post Notice |

### 3.2 User Management
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| ADM-10 | List Students | Paginated table: Name, Username, Email, Status (badge), Actions |
| ADM-11 | List Teachers | Same as students |
| ADM-12 | Live Search | Filter by name/username/email (debounced, client-side) |
| ADM-13 | Server-Side Search | `UserDAO.searchByRole()` with LIKE escaping |
| ADM-14 | Add User | Modal/form: username, email, password, role, full name, phone, gender, DOB, address |
| ADM-15 | Edit User | Pre-filled form; optional password change; role immutable |
| ADM-16 | Enable/Disable | Toggle `active` flag; instant UI update via form POST |
| ADM-17 | Delete User | Confirm modal; prevents ADMIN deletion; cascades enrollments/attendance/marks |
| ADM-18 | Client-Side Sort | Click column headers (Name, Username, Email, Status) |
| ADM-19 | Row Count Badge | Live count updates with filter |

### 3.3 Course Management
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| ADM-20 | List Courses | Table: Code, Title, Credits, Semester, Teacher (name), Actions |
| ADM-21 | Add Course | Form: code (unique), title, credits, semester, teacher (dropdown from TEACHER role) |
| ADM-22 | Edit Course | Pre-filled; teacher reassignment allowed |
| ADM-23 | Delete Course | Confirm; cascades enrollments/attendance/marks |
| ADM-24 | Teacher Dropdown | Populated from `UserDAO.getByRole("TEACHER")` |

### 3.4 Notices
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| ADM-30 | List Notices | Table: Title, Audience, Author, Date, Actions |
| ADM-31 | Create Notice | Form: title, body (textarea), audience (ALL/STUDENT/TEACHER) |
| ADM-32 | Delete Notice | Confirm; only author or admin can delete |

---

## 4. Teacher Portal

### 4.1 Dashboard
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| TCH-01 | My Courses | Cards: Code, Title, Semester, Actions (Attendance, Marks) |
| TCH-02 | Course Count Stat | Total assigned courses |
| TCH-03 | Notice Count Stat | Active notices (TEACHER + ALL audience) |
| TCH-04 | Recent Notices | List latest 5 notices |

### 4.2 Attendance
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| TCH-10 | Select Course | Dropdown/link from dashboard/courses list |
| TCH-11 | Enrolled Students List | Table: Student Name, Username, Status (radio: Present/Absent) |
| TCH-12 | Date Picker | Default today; editable |
| TCH-13 | Bulk Save | Single POST saves all rows; `ON DUPLICATE KEY UPDATE` |
| TCH-14 | CSV Export | `teacher/export-attendance?courseId=X` → downloads `CODE-attendance.csv` |
| TCH-15 | Export Authorization | Only assigned teacher or admin can export |
| TCH-16 | CSV Format | Header: Course, Student, Username, Attended, Total, Percent |

### 4.3 Marks
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| TCH-20 | Select Course | Same as attendance |
| TCH-21 | Exam Type Selector | MIDTERM / FINAL / INTERNAL (dropdown) |
| TCH-22 | Max Marks Input | Default 100; editable |
| TCH-23 | Marks Grid | Table: Student, Username, Marks (input), Existing value pre-filled |
| TCH-24 | Bulk Save | Single POST; `ON DUPLICATE KEY UPDATE` |
| TCH-25 | CSV Export | `teacher/export-marks?courseId=X` → downloads `CODE-marks.csv` |
| TCH-26 | Export Authorization | Same as attendance |
| TCH-27 | CSV Format | Header: Course, Student, Username, Exam, Marks, Max, Percent |

### 4.4 Notices
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| TCH-30 | List Notices | Same as admin but filtered to TEACHER/ALL audience |
| TCH-31 | Create Notice | Audience: STUDENT or ALL (not TEACHER-only) |

---

## 5. Student Portal

### 5.1 Dashboard
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| STU-01 | Stats Cards | Enrolled Courses, Overall Attendance %, Average Score % |
| STU-02 | My Courses Table | Code, Title, Teacher (TBA if null) |
| STU-03 | Notices Feed | Latest 4 notices (STUDENT + ALL audience) |

### 5.2 Courses
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| STU-10 | Enrolled Courses | Table with Unenroll button (confirm) |
| STU-11 | Available Courses | Table with Enroll button (only courses not enrolled) |
| STU-12 | Enroll Action | POST `/student/enroll`; `INSERT IGNORE`; redirect back |
| STU-13 | Unenroll Action | POST `/student/unenroll`; confirm modal; redirect back |

### 5.3 Attendance
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| STU-20 | Summary Table | Per course: Code, Title, Attended, Total, Percentage (progress bar) |
| STU-21 | Progress Bar | Synthesized from `data-pct`; green ≥75%, amber >0%, red 0% |
| STU-22 | Overall Stats | Dashboard cards calculate weighted average |

### 5.4 Marks
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| STU-30 | Marks Table | Per course: Code, Title, Exam Type, Marks, Max, Percentage |
| STU-31 | Grade Calculation | Auto letter grade: A+ ≥90, A ≥80, B+ ≥70, B ≥60, C ≥50, D ≥40, F <40 |
| STU-32 | Average Score | Dashboard card: mean of all exam percentages |

### 5.5 Notices
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| STU-40 | Notice List | All STUDENT + ALL audience; paginated if >10 |
| STU-41 | Notice Detail | Title, date, author, full body |

### 5.6 Profile
| ID | Feature | Acceptance Criteria |
|----|---------|---------------------|
| STU-50 | View Profile | Read-only: username, email, full name, phone, gender, DOB, address |
| STU-51 | Edit Profile | Form: full name, email, phone, gender, DOB, address; saves to DB |
| STU-52 | Change Password | Current password not required (session auth); min 6 chars; bcrypt |
| STU-53 | Success Feedback | `?saved=1`, `?pwchanged=1` → toast notification |

---

## 6. Security Features

| ID | Feature | Implementation |
|----|---------|----------------|
| SEC-01 | bcrypt Password Hashing | `jbcrypt` cost 10; legacy SHA-256 upgraded on first login |
| SEC-02 | CSRF Protection | Per-session token; validated on all POST; injected via `${csrfField}` |
| SEC-03 | Security Headers | CSP, X-Frame-Options: DENY, X-Content-Type-Options: nosniff, Referrer-Policy |
| SEC-04 | SQL Injection Prevention | 100% PreparedStatement; zero string concatenation |
| SEC-05 | XSS Prevention | JSTL `<c:out>` / `${fn:escapeXml()}` in all JSPs |
| SEC-06 | Clickjacking Protection | `X-Frame-Options: DENY` + CSP `frame-ancestors 'none'` |
| SEC-07 | MIME Sniffing Protection | `X-Content-Type-Options: nosniff` |
| SEC-08 | Referrer Policy | `strict-origin-when-cross-origin` |
| SEC-09 | Login Rate Limiting | In-memory `ConcurrentHashMap`; 5 attempts / 10 min |
| SEC-10 | Session Security | `HttpOnly`; `Secure` (in prod); `SameSite=Strict`; 30-min timeout |
| SEC-11 | CSV Export Authorization | Teacher can only export own courses; admin all |

---

## 7. UI/UX Features

| ID | Feature | Description |
|----|---------|-------------|
| UI-01 | Design System | CSS custom properties (primitive→semantic→component) |
| UI-02 | Dark/Light Mode | `[data-theme]` on `<html>`; persisted to localStorage; system preference |
| UI-03 | Responsive Layout | Sidebar drawer <900px; grid collapse <960px |
| UI-04 | Animations | Staggered reveal, count-up, progress bars, ripple, shimmer |
| UI-05 | Reduced Motion | `@media (prefers-reduced-motion)` disables all animations |
| UI-06 | Accessibility (WCAG 2.2 AA) | Semantic HTML, focus-visible, contrast ≥4.5:1, ARIA labels, live regions |
| UI-07 | Toast Notifications | Stack, auto-dismiss, action mapping from URL params |
| UI-08 | Top Loading Bar | Animated gradient on navigation/form submit |
| UI-09 | Table Sort/Filter | Client-side sort (numeric + locale); live filter with hit highlighting |
| UI-10 | Skeleton Screens | Shimmer placeholders on initial paint |
| UI-11 | Keyboard Shortcuts | `/` = focus search; `Esc` = close drawer |
| UI-12 | Clock | Live date/time in topbar (locale-aware) |
| UI-13 | Password Toggle | Show/hide password on login |
| UI-14 | Form Validation | Inline client-side + server-side; error toasts |

---

## 8. Data Integrity & Validation

| ID | Feature | Implementation |
|----|---------|----------------|
| DAT-01 | Unique Constraints | DB: username, email, course_code, enrollment(student,course), attendance(student,course,date), marks(student,course,exam) |
| DAT-02 | Foreign Keys | CASCADE/SET NULL as appropriate; referential integrity enforced |
| DAT-03 | Input Sanitization | Server-side validation in servlets; DAO uses PreparedStatement |
| DAT-04 | Search Injection Safety | `UserDAO.searchByRole()` escapes `%`, `_`, `\` for LIKE |
| DAT-05 | CSV Injection Prevention | `csv()` helper escapes commas, quotes, newlines |
| DAT-06 | Transaction Safety | Single-statement operations; multi-row uses batch/loop |

---

## 9. Performance & Scalability

| ID | Feature | Implementation |
|----|---------|----------------|
| PER-01 | Connection Pooling | HikariCP: 10 max, 2 min-idle, 10s timeout |
| PER-02 | PreparedStatement Reuse | Implicit via pool; no statement caching needed at this scale |
| PER-03 | Indexes | PK on all IDs; UNIQUE on business keys; FK indexes implicit |
| PER-04 | Pagination (Future) | `LIMIT/OFFSET` for large tables |
| PER-05 | Client-Side Enhancement | Sort/filter/count-up in browser; zero server round-trips |
| PER-06 | Static Assets | CSS/JS served directly by Tomcat; no build pipeline |

---

## 10. Deployment & Operations

| ID | Feature | Details |
|----|---------|---------|
| OPS-01 | WAR Packaging | `mvn clean package` → `target/CollegeApp.war` |
| OPS-02 | Tomcat 10.1+ | Jakarta EE 10 (Servlet 6.0) |
| OPS-03 | Database Init | `mysql -u root -p < database/college_db.sql` |
| OPS-04 | Configuration | Edit `DBUtil.java` for DB credentials (externalize in prod) |
| OPS-05 | Default Admin | Seeded in SQL: `admin` / `Admin@123` (bcrypt-upgraded on first login) |
| OPS-06 | Logging | SLF4J + slf4j-simple (stdout); upgrade to Logback in prod |

---

## 11. Future Enhancements (Backlog)

| ID | Feature | Priority | Effort |
|----|---------|----------|--------|
| FUT-01 | Pagination | High | Medium |
| FUT-02 | Remember Me / Refresh Tokens | High | Medium |
| FUT-03 | Email Notifications | Medium | High |
| FUT-04 | File Upload (assignments, avatars) | Medium | High |
| FUT-05 | REST API + Swagger | Medium | High |
| FUT-06 | Audit Logging | High | Medium |
| FUT-07 | Multi-tenancy | Low | High |
| FUT-08 | WebSocket (real-time notices) | Low | High |
| FUT-09 | Reporting/Analytics Dashboard | Medium | High |
| FUT-10 | Mobile App (React Native/Flutter) | Low | Very High |
| FUT-11 | SSO (SAML/OIDC) | Medium | High |
| FUT-12 | Automated Testing (Playwright) | High | Medium |
| FUT-13 | CI/CD Pipeline | High | Medium |
| FUT-14 | Kubernetes Deployment | Low | High |

---

## 12. Traceability Matrix

| Requirement | Component | Test Case |
|-------------|-----------|-----------|
| User can login | LoginServlet, UserDAO, login.jsp | Valid/invalid creds, rate limit, session fixation |
| Admin manages users | AdminServlet, UserDAO, users.jsp | CRUD, search, sort, toggle, delete |
| Teacher marks attendance | TeacherServlet, AcademicDAO, attendance.jsp | Mark, save, export CSV, authz |
| Student enrolls | StudentServlet, CourseDAO, courses.jsp | Enroll/unenroll, conflict handling |
| Security headers present | SecurityFilter | CSP, X-Frame-Options, nosniff, Referrer-Policy |
| CSRF blocked | SecurityFilter | POST without token → 403 |
| Dark mode persists | app.js, localStorage | Toggle → reload → theme retained |
| Accessibility | All JSPs + style.css | axe-core scan; keyboard nav; contrast |

---

*This specification is the source of truth for all features. Implementation must satisfy all acceptance criteria.*