# CollegeHub — Comprehensive Documentation Index

## Quick Links

| Document | Description |
|----------|-------------|
| [Architecture](ARCHITECTURE.md) | Complete system architecture (MVC, RBAC, data flow) |
| [Design System](DESIGN_SYSTEM.md) | CSS tokens, components, animations, accessibility |
| [Features](FEATURES.md) | Full feature inventory with acceptance criteria |
| [Test Plan](TEST_PLAN.md) | Unit, integration, security, a11y, E2E, performance |
| [API Reference](API_REFERENCE.md) | REST endpoints, request/response schemas |
| [Deployment](DEPLOYMENT.md) | Build, configure, deploy, monitor |
| [Security](SECURITY.md) | Hardening measures, threat model, compliance |
| [Accessibility](ACCESSIBILITY.md) | WCAG 2.2 AA compliance, testing, remediation |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
│  JSP Views + CSS Design System + Vanilla JS (app.js)            │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       CONTROLLER LAYER                           │
│  Servlets (Login, Admin, Teacher, Student, Logout, Health, API) │
│  Filters (AuthFilter, SecurityFilter)                           │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        SERVICE LAYER                             │
│  DAOs (UserDAO, CourseDAO, AcademicDAO)                         │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA ACCESS LAYER                          │
│  DBUtil (HikariCP Pool + bcrypt + Audit Logging)                │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         DATABASE (MySQL 8+)                      │
│  users • departments • courses • enrollments • attendance       │
│  • marks • notices                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Language | Java | 17+ |
| Web Framework | Jakarta EE 10 (Servlet 6.0) | 6.0 |
| View | JSP + JSTL | 3.0 |
| Database | MySQL | 8.0+ |
| Connection Pool | HikariCP | 5.1 |
| Password Hashing | jBCrypt | 0.4 |
| Logging | SLF4J + slf4j-simple | 2.0 |
| Build | Maven | 3.9+ |
| Server | Apache Tomcat | 10.1+ |
| Frontend | CSS Custom Properties + Vanilla JS | ES2020 |

---

## Key Features by Role

### 🎓 Admin
- Dashboard with live stats
- User management (CRUD + search + pagination + enable/disable/delete)
- Course management (CRUD + teacher assignment)
- Notices (create/delete, audience targeting)

### 👨‍🏫 Teacher
- Dashboard (assigned courses + notices)
- Attendance marking (bulk save + CSV export)
- Marks entry (bulk save + CSV export + grade calc)
- Notices (post to students)

### 🎒 Student
- Dashboard (enrolled courses, attendance %, average score)
- Course enrollment/unenrollment
- Attendance view (progress bars)
- Marks view (with letter grades A+…F)
- Profile edit + password change
- Notices feed

---

## Security Highlights

| Measure | Implementation |
|---------|----------------|
| Password Hashing | bcrypt (cost 12), legacy SHA-256 auto-upgrade |
| CSRF Protection | Per-session token, validated on all POST |
| Security Headers | CSP, X-Frame-Options: DENY, nosniff, Referrer-Policy |
| SQL Injection | 100% PreparedStatement |
| XSS Prevention | JSTL `<c:out>` / `${fn:escapeXml()}` |
| Rate Limiting | 5 failed logins / 10 min per username |
| Session Security | HttpOnly, Secure, SameSite=Strict, 30-min timeout |
| Authorization | Role-based (AuthFilter) + resource ownership checks |

---

## UI/UX Highlights

| Feature | Details |
|---------|---------|
| Design System | 3-layer CSS tokens (primitive → semantic → component) |
| Dark/Light Mode | `[data-theme]` + localStorage + system preference |
| Responsive | Sidebar drawer <900px; grid collapse <960px |
| Animations | Staggered reveal, count-up, progress bars, ripple, shimmer |
| Accessibility | WCAG 2.2 AA: semantic HTML, focus-visible, contrast ≥4.5:1, ARIA |
| Reduced Motion | `@media (prefers-reduced-motion)` disables all animations |
| Zero Dependencies | No npm, no build step, vanilla JS only |

---

## Quick Start

### Prerequisites
- JDK 17+
- Maven 3.9+
- MySQL 8.0+
- Apache Tomcat 10.1+

### 1. Database Setup
```bash
mysql -u root -p < database/college_db.sql
```

### 2. Configure Database Credentials
Edit `src/main/java/com/college/util/DBUtil.java`:
```java
private static final String URL = "jdbc:mysql://localhost:3306/college_db?...";
private static final String USER = "your_db_user";
private static final String PASS = "your_db_password";
```
*Or set environment variables: `DB_URL`, `DB_USER`, `DB_PASS`*

### 3. Build WAR
```bash
mvn clean package
# → target/CollegeApp.war
```

### 4. Deploy to Tomcat
```bash
cp target/CollegeApp.war $TOMCAT_HOME/webapps/
$TOMCAT_HOME/bin/startup.sh
```

### 5. Access Application
```
http://localhost:8080/CollegeApp/
```

### 6. Default Login
| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `Admin@123` |

> **Note**: Default admin password is bcrypt-upgraded on first login.

---

## Project Structure

```
CollegeApp/
├── src/main/
│   ├── java/com/college/
│   │   ├── dao/           # UserDAO, CourseDAO, AcademicDAO
│   │   ├── filter/        # AuthFilter, SecurityFilter
│   │   ├── model/         # User, Course, Notice
│   │   ├── servlet/       # Login, Logout, Admin, Teacher, Student, Health, API
│   │   └── util/          # DBUtil, LoginRateLimiter
│   ├── webapp/
│   │   ├── WEB-INF/
│   │   │   ├── views/     # JSPs (layout/, admin/, teacher/, student/, login.jsp)
│   │   │   └── web.xml    # Filter mappings, welcome-file
│   │   ├── css/style.css  # Complete design system
│   │   └── js/app.js      # Reactive interaction layer
│   └── resources/
├── database/college_db.sql
├── pom.xml
├── ARCHITECTURE.md
├── DESIGN_SYSTEM.md
├── FEATURES.md
├── TEST_PLAN.md
├── API_REFERENCE.md
├── DEPLOYMENT.md
├── SECURITY.md
├── ACCESSIBILITY.md
└── README.md
```

---

## API Endpoints (Future-Ready)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/health` | GET | None | Health check + pool stats |
| `/api/stats` | GET | API Key | System statistics |
| `/api/users` | GET | API Key | Paginated user list |
| `/api/courses` | GET | API Key | Course catalog |

*Set `API_KEY` environment variable for API access.*

---

## Development Workflow

### Code Quality
```bash
# Compile check
mvn compile

# Run tests
mvn test

# Full verify (tests + integration)
mvn verify

# Security scan
mvn org.owasp:dependency-check-maven:check

# Accessibility audit
python -m a11y_audit target/CollegeApp --ci
```

### Hot Reload (Development)
```bash
# Use Tomcat's context reloading or IDE hot deploy
# No frontend build step needed — edit CSS/JS directly
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_URL` | `jdbc:mysql://localhost:3306/college_db?...` | JDBC URL |
| `DB_USER` | `root` | Database username |
| `DB_PASS` | `system` | Database password |
| `API_KEY` | `dev-key-123` | API authentication key |
| `BCRYPT_COST` | `12` | bcrypt cost factor |

### Production Checklist

- [ ] Externalize DB credentials (environment variables / secrets manager)
- [ ] Enable HTTPS (terminate at load balancer or Tomcat)
- [ ] Configure Logback with JSON output + log aggregation
- [ ] Set up Prometheus metrics endpoint (`/actuator/prometheus`)
- [ ] Configure connection pool for expected load
- [ ] Enable CSP `report-uri` for violation reporting
- [ ] Set up automated backups for MySQL
- [ ] Configure health check endpoint for orchestration

---

## Monitoring & Observability

| Concern | Current | Production Recommendation |
|---------|---------|---------------------------|
| Logging | SLF4J simple (stdout) | Logback + JSON + correlation IDs |
| Metrics | None | Micrometer + Prometheus |
| Tracing | None | OpenTelemetry Java agent |
| Health | `/health` endpoint | Spring Boot Actuator style |
| Errors | Console | Sentry / Rollbar |

---

## Extending the System

### Adding a New Role
1. Add to `users.role` enum in `college_db.sql`
2. Update `AuthFilter` role logic
3. Create servlet mapping in `web.xml`
4. Implement role-specific servlet + JSPs
5. Update navigation in `layout/top.jsp`

### Adding a New Resource
1. Create DAO with CRUD + search
2. Create servlet with `@WebServlet("/role/*")`
3. Create JSPs in `WEB-INF/views/role/`
4. Add filter mapping in `web.xml`
5. Update navigation + permissions

### Adding REST Endpoints
1. Extend `ApiServlet` or create new `@WebServlet("/api/v1/*")`
2. Use `jakarta.json` or Jackson (add dependency)
3. Implement proper authentication (JWT/OAuth)
4. Add OpenAPI/Swagger documentation

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## Support

- **Issues**: GitHub Issues
- **Security**: Report privately via `security@collegehub.example.com`
- **Documentation**: This repository's `/docs` folder

---

*CollegeHub — Built with Java, Jakarta EE, and modern web standards.*