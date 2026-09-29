# Mangaud CollegeHub

A full-stack college management system built on **JSP + Servlets (Jakarta EE 10) + JDBC + MySQL 8**,
deployed as a WAR to Tomcat 10.1. No frameworks, no build-time templating, no Docker.

---

## Quick start

**Double-click `run.bat`** (in the folder that contains `CollegeApp`, `apache-tomcat-10.1` and `maven`).

Or from a terminal:

```bat
run.bat
```

The script does everything end to end and opens your browser when the app is healthy:

1. Finds a JDK (17 or newer)
2. Finds Maven and MySQL
3. Starts the MySQL service if it is stopped
4. Creates the database, applies the schema + migration, loads demo data
5. Builds `CollegeApp.war`
6. Deploys it to Tomcat and starts the server
7. Waits until `/health` reports `UP`
8. Opens <http://localhost:8080/CollegeApp/>

When it finishes it shows a small menu:

| Key | Action |
|-----|--------|
| `R` | Reopen the browser |
| `L` | Open the Tomcat log in Notepad |
| `S` | Stop the server |
| `Q` | Quit the window (leaves the server running) |

### Requirements

- **JDK 17+** (tested on JDK 25)
- **MySQL 8** running, with credentials `root` / `system`
  - Change them at the top of `run.bat` if yours differ
- Maven and Tomcat are already bundled in this folder

---

## Demo sign-in

The login page lists every account grouped by role. **Click any tile to sign in
instantly** — no typing. Or type the credentials yourself:

| Role | Username | Password | Lands on |
|------|----------|----------|----------|
| Administrator | `admin` | `Admin@123` | Admin dashboard |
| Vice Principal | `viceprincipal` | `Vice@123` | Admin dashboard |
| Teacher | `teacher1` … `teacher4` | `Teacher@123` | Teacher dashboard |
| Student | `student1` … `student8` | `Student@123` | Student dashboard |
| Parent | `parent1` | `Parent@123` | Student dashboard |
| Accountant | `accountant` | `Accounts@123` | Fees |
| Librarian | `librarian` | `Library@123` | Library |
| Hostel Warden | `warden` | `Warden@123` | Hostel |
| Transport Manager | `transport` | `Transport@123` | Transport |

Passwords are stored as **bcrypt hashes (cost 12)**, not plaintext. The demo
panel is a UI convenience only — to hide it, start Tomcat with
`-Dcollege.demo.login=false`.

---

## Modules

| Module | Path | Who |
|--------|------|-----|
| Administration | `/admin/*` | Admin |
| Academics (years, semesters, timetable, exams, results) | `/academic/*` | Teacher, Student |
| Attendance & marks | `/teacher/*`, `/student/*` | Teacher, Student |
| Fees & scholarships | `/fee/*` | Accountant, Student |
| Library | `/library/*` | Librarian, Student |
| Hostel | `/hostel/*` | Warden, Student |
| Transport | `/transport/*` | Manager, Student |
| Leave | `/leave/*` | Everyone |
| Messaging & notifications | `/messages/*` | Everyone |
| Events | `/events/*` | Everyone |
| Grievances | `/grievance/*` | Student, Teacher |
| Health / API | `/health`, `/api/*` | — |

---

## Project layout

```
run.bat                     one-click deploy + launch
CollegeApp/
  pom.xml                   Maven WAR build
  database/
    college_db.sql          48-table schema
    migrate_schema.sql      idempotent migration (role enum, natural keys, indexes)
    seed_demo_data.sql      demo users + data (self-resetting, re-runnable)
  src/main/java/com/college/
    filter/                 AuthFilter (RBAC), SecurityFilter (CSRF + headers)
    servlet/                one servlet per module
    dao/                    JDBC data access
    model/                  domain objects
    util/                   DBUtil, ViewHelper, DemoLogin, LoginRateLimiter
  src/main/webapp/
    WEB-INF/views/          JSP views
    css/style.css           Mangaud design system
    img/                    logo.svg, logo-mark.svg
    js/app.js
apache-tomcat-10.1/         bundled server
maven/                      bundled Maven
```

---

## Security

- **bcrypt** password hashing (cost 12) with transparent rehash on cost change
- **CSRF** token per session, validated on every POST; rotates on failure
- **Session fixation** protection via `changeSessionId()` on login
- **RBAC** by role *sets* per module (students can read their own fees, books,
  hostel, transport and leave)
- **Rate limiting** on login (5 failures / 10 min per username)
- Security headers: CSP, `X-Frame-Options`, `nosniff`, `Referrer-Policy`
- Session cookie is `HttpOnly` + `SameSite=Strict`
- All SQL goes through `PreparedStatement`

### Before deploying anywhere public

- Set `DB_USER` / `DB_PASS` / `DB_URL` as environment variables instead of relying
  on the defaults
- Start Tomcat with `-Dcollege.demo.login=false` to hide the demo panel
- Serve over HTTPS and set `<secure>true</secure>` in `web.xml`
- Delete the `database/backup/` dumps if any

---

## Troubleshooting

**"Cannot connect to MySQL"** — start the service, then re-run:
```bat
net start MySQL80
```

**Port 8080 already in use** — close whatever owns it, or change `PORT` near the
top of `run.bat`.

**Browser shows a stale layout** — press `Ctrl+F5`. The stylesheet is
versioned automatically (`style.css?v=N`), so this should rarely be needed; bump
`STYLE_VERSION` in `src/main/resources/app.properties` after editing the CSS.

**Where are the logs?** — `apache-tomcat-10.1\logs\`, or press `L` in the script menu.
