# CollegeHub — Security Documentation

## Threat Model

### Assets
| Asset | Classification | Impact if Compromised |
|-------|----------------|----------------------|
| User credentials (bcrypt hashes) | High | Identity theft, lateral movement |
| Student PII (name, email, phone, address) | High | Privacy violation, GDPR/CCPA fines |
| Academic records (attendance, marks) | Medium | Academic integrity, FERPA violation |
| Admin session tokens | Critical | Full system takeover |
| Database | Critical | Data exfiltration, destruction |

### Trust Boundaries
```
Internet → [Nginx TLS] → Tomcat → [HikariCP] → MySQL
                ↑              ↑
            WAF/Rate        AuthFilter
            Limit           SecurityFilter
```

### Attack Surface
| Entry Point | Controls |
|-------------|----------|
| `/login` | Rate limiting, bcrypt, CSRF, secure headers |
| `/admin/*` | AuthFilter (RBAC), CSRF, audit logging |
| `/teacher/*` | AuthFilter (RBAC + ownership), CSRF |
| `/student/*` | AuthFilter (RBAC + ownership), CSRF |
| `/api/*` | API key auth, rate limiting |
| `/health` | Public, no sensitive data |

---

## Security Controls Matrix

| Control | Implementation | Verification |
|---------|----------------|--------------|
| **Authentication** | bcrypt (cost 12), session-based | Unit test: hash/verify, upgrade path |
| **Authorization** | AuthFilter (role + ownership) | Integration test: role matrix |
| **CSRF Protection** | Per-session token, validated on POST | SecurityFilter test: missing/invalid token → 403 |
| **SQL Injection** | 100% PreparedStatement | Code review: zero string concat in DAOs |
| **XSS Prevention** | JSTL `<c:out>`, CSP | Automated scan: no unescaped output |
| **Clickjacking** | `X-Frame-Options: DENY`, CSP `frame-ancestors 'none'` | Header check |
| **MIME Sniffing** | `X-Content-Type-Options: nosniff` | Header check |
| **Referrer Leakage** | `Referrer-Policy: strict-origin-when-cross-origin` | Header check |
| **Session Security** | HttpOnly, Secure, SameSite=Strict, 30-min timeout | Cookie inspection |
| **Rate Limiting** | 5 attempts/10min per username (in-memory) | Load test: burst >5 blocked |
| **Password Policy** | Min 6 chars (UI), bcrypt server-side | UI validation + server hash |
| **Audit Logging** | SLF4J structured logs (login, data changes) | Log review |
| **Secure Headers** | CSP, HSTS (via Nginx), XSS Protection | SecurityHeaders.com scan |
| **Dependency Scanning** | OWASP Dependency Check in CI | CI gate |

---

## Secure Coding Practices

### 1. Database Access
```java
// ✅ GOOD: PreparedStatement with parameters
String sql = "SELECT * FROM users WHERE username=? AND active=1";
try (PreparedStatement p = c.prepareStatement(sql)) {
    p.setString(1, username);
    // ...
}

// ❌ BAD: String concatenation (SQL injection)
String sql = "SELECT * FROM users WHERE username='" + username + "'";
```

### 2. Output Encoding
```jsp
<!-- ✅ GOOD: JSTL auto-escapes -->
<c:out value="${user.fullName}" />

<!-- ✅ GOOD: fn:escapeXml for attributes -->
<input value="${fn:escapeXml(user.email)}">

<!-- ❌ BAD: Raw output (XSS) -->
<%= user.fullName %>
${user.fullName}
```

### 3. CSRF Token Usage
```jsp
<!-- Every POST form must include -->
<form method="post" action="...">
    ${csrfField}
    <!-- form fields -->
</form>
```

### 4. Authorization Checks
```java
// ✅ GOOD: Ownership verification before sensitive operation
Course c = courseDAO.findById(courseId);
if (c == null || (!"ADMIN".equals(user.getRole()) &&
        (c.getTeacherId() == null || c.getTeacherId() != user.getId()))) {
    resp.sendError(HttpServletResponse.SC_FORBIDDEN);
    return;
}
```

### 5. Error Handling
```java
// ✅ GOOD: Generic error messages, log details server-side
} catch (SQLException e) {
    log.error("DB error", e);  // Detailed log
    return false;              // Generic return
}

// ❌ BAD: Exposing stack traces to users
} catch (SQLException e) {
    throw new RuntimeException(e);  // Leaks schema info
}
```

---

## Incident Response

### 1. Compromised Credentials
1. Force password reset for affected users
2. Invalidate all sessions: `TRUNCATE TABLE sessions` (if session table exists) or restart Tomcat
3. Rotate API keys
4. Review audit logs for suspicious activity

### 2. SQL Injection Attempt
1. Block attacking IP at WAF/Nginx
2. Review query logs for successful exploitation
3. Verify no data exfiltration
4. Deploy WAF rule

### 3. XSS Payload Detected
1. Identify vulnerable output point
2. Apply `<c:out>` / `${fn:escapeXml()}`
3. Deploy fix
4. Scan all JSPs for similar patterns

### 4. Session Hijacking
1. Invalidate all sessions
2. Force re-login
3. Review `SecurityFilter` CSP effectiveness
4. Consider implementing CSRF token rotation

---

## Compliance Mapping

| Standard | Requirement | CollegeHub Control |
|----------|-------------|-------------------|
| **OWASP Top 10 2021** | | |
| A01: Broken Access Control | RBAC + ownership checks | AuthFilter + servlet checks |
| A02: Cryptographic Failures | bcrypt, TLS | DBUtil, Nginx TLS |
| A03: Injection | PreparedStatement, CSP | DAO pattern, SecurityFilter |
| A04: Insecure Design | Threat model, secure defaults | This doc, secure config |
| A05: Security Misconfiguration | Secure headers, minimal surface | SecurityFilter, server.xml |
| A06: Vulnerable Components | Dependency Check in CI | OWASP DC Maven plugin |
| A07: Auth Failures | Rate limiting, bcrypt, secure sessions | LoginServlet, DBUtil |
| A08: Software Integrity | Signed WAR, verified deps | Maven Central, checksums |
| A09: Logging Failures | Structured audit logging | DBUtil.audit* |
| A10: SSRF | No outbound requests from user input | No user-controlled URLs |
| **GDPR** | | |
| Art. 5: Lawfulness | Consent via registration | Admin creates users |
| Art. 12-22: Data Subject Rights | Profile edit, delete | StudentServlet, UserDAO.delete |
| Art. 25: Privacy by Design | Minimal data collection | Only required fields |
| Art. 32: Security of Processing | Encryption, access controls | bcrypt, RBAC, TLS |
| **FERPA** | | |
| §99.30: Access Control | Role-based access | AuthFilter |
| §99.31: Audit Trail | Audit logging | DBUtil.auditDataChange |

---

## Penetration Testing Checklist

### Pre-Test
- [ ] Staging environment mirrors production
- [ ] Test accounts created (admin, teacher, student)
- [ ] WAF/IPS in monitoring mode (not blocking)
- [ ] Audit logging enabled at DEBUG level

### Test Cases

| Category | Tests |
|----------|-------|
| **Authentication** | Brute force, credential stuffing, session fixation, password reset, remember me |
| **Authorization** | Horizontal (student→student), vertical (student→admin), IDOR (course access), API key abuse |
| **Injection** | SQLi (login, search, API), NoSQLi (N/A), LDAPi (N/A), Command injection (N/A) |
| **XSS** | Reflected (search, error pages), Stored (notices, profile), DOM (app.js) |
| **CSRF** | State-changing operations (all POST forms) |
| **Security Headers** | CSP, HSTS, X-Frame-Options, nosniff, Referrer-Policy |
| **Session** | Timeout, rotation, secure flags, concurrency |
| **Business Logic** | Enrollment limits, grade manipulation, notice audience bypass |
| **API** | Rate limiting, auth bypass, parameter pollution, mass assignment |

### Post-Test
- [ ] All Critical/High findings remediated
- [ ] Medium findings risk-accepted or scheduled
- [ ] Retest critical findings
- [ ] Update threat model
- [ ] Document lessons learned

---

## Vulnerability Management

### Dependency Updates
```bash
# Monthly
mvn versions:display-dependency-updates
mvn org.owasp:dependency-check-maven:check

# On CVE alert
mvn dependency:tree | grep <vulnerable-artifact>
# Update version in pom.xml → test → deploy
```

### Security Patches
| Component | Update Cadence | Process |
|-----------|----------------|---------|
| Java (JDK) | Quarterly (CPU) | Test on staging → deploy |
| Tomcat | Monthly | Test on staging → deploy |
| MySQL | Quarterly | Test on staging → deploy |
| Maven Deps | Monthly | Dependabot/Renovate PRs |
| OS | Monthly | Unattended-upgrades / patch management |

---

## Security Contacts

| Role | Contact |
|------|---------|
| Security Team | security@collegehub.example.com |
| Incident Response | incident@collegehub.example.com |
| Bug Bounty | bounty@collegehub.example.com |

---

## Security Review Checklist (Per Release)

- [ ] No new `RuntimeException` exposing stack traces
- [ ] All new POST forms include `${csrfField}`
- [ ] All new DAO methods use `PreparedStatement`
- [ ] All new JSP output uses `<c:out>` or `${fn:escapeXml()}`
- [ ] New endpoints added to `AuthFilter`/`SecurityFilter` mappings
- [ ] New sensitive operations have ownership checks
- [ ] Audit logging added for new data mutations
- [ ] Dependency check passes (no new Critical/High CVEs)
- [ ] CSP allows new inline scripts/styles (if any) via nonce/hash
- [ ] Rate limiting considered for new public endpoints

---

*Security is a process, not a product. Review this document quarterly.*