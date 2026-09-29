# CollegeHub — Deployment Guide

## Overview

Production deployment guide for CollegeHub WAR on Apache Tomcat 10.1+ with MySQL 8+.

---

## Windows: one-click local setup

> Running this on your own machine? Skip everything below and just double-click
> **`run.bat`** in the project root. It finds the JDK, starts MySQL, applies the
> schema + migration + demo data, builds the WAR, deploys to Tomcat, waits until
> the app is healthy, and opens your browser at
> <http://localhost:8080/CollegeApp/>.
>
> Requires JDK 17+ and MySQL 8 (credentials `root` / `system`). Maven and
> Tomcat are already bundled in the project folder.

### Database script order

The three SQL files must be applied **in this order**, and each is safe to re-run:

1. `database/college_db.sql` - the 48-table schema
2. `database/migrate_schema.sql` - widens `users.role` to all 8 roles, adds
   natural keys and performance indexes (idempotent)
3. `database/seed_demo_data.sql` - demo users and data (clears and reloads)

```bash
mysql -u root -p < database/college_db.sql
mysql -u root -p college_db < database/migrate_schema.sql
mysql -u root -p college_db < database/seed_demo_data.sql
```

> `migrate_schema.sql` uses a `DELIMITER` directive, which `mysql` only honours
> when the script arrives on stdin - so use `< file`, not `source file`.

---

## Prerequisites

| Component | Version | Notes |
|-----------|---------|-------|
| Java | 17+ (LTS) | Temurin/OpenJDK recommended |
| Maven | 3.9+ | For building WAR |
| MySQL | 8.0+ | InnoDB, utf8mb4 |
| Tomcat | 10.1+ | Jakarta EE 10 (Servlet 6.0) |
| OS | Linux (Ubuntu 22.04+/RHEL 9+) | systemd for service management |

---

## 1. Database Setup

### 1.1 Create Database & User
```sql
-- Run as MySQL root
CREATE DATABASE college_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'college_app'@'%' IDENTIFIED BY 'strong-random-password';
GRANT ALL PRIVILEGES ON college_db.* TO 'college_app'@'%';
FLUSH PRIVILEGES;
```

### 1.2 Apply Schema
```bash
mysql -u college_app -p college_db < database/college_db.sql
```

### 1.3 Verify
```sql
USE college_db;
SHOW TABLES;
SELECT username, role FROM users WHERE username='admin';
```

---

## 2. Build WAR

### 2.1 Configure Credentials

**Option A: Environment Variables (Recommended)**
```bash
export DB_URL="jdbc:mysql://localhost:3306/college_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTF-8"
export DB_USER="college_app"
export DB_PASS="strong-random-password"
export BCRYPT_COST=12
export API_KEY="production-api-key-change-me"
```

**Option B: Edit Source (Not for Production)**
Edit `src/main/java/com/college/util/DBUtil.java`:
```java
private static final String URL = System.getenv().getOrDefault("DB_URL", "jdbc:mysql://...");
private static final String USER = System.getenv().getOrDefault("DB_USER", "root");
private static final String PASS = System.getenv().getOrDefault("DB_PASS", "system");
```

### 2.2 Build
```bash
mvn clean package
# Output: target/CollegeApp.war
```

### 2.3 Verify WAR
```bash
unzip -l target/CollegeApp.war | head -30
# Should contain: WEB-INF/classes/, WEB-INF/lib/, css/, js/, WEB-INF/views/
```

---

## 3. Tomcat Configuration

### 3.1 Install Tomcat 10.1+
```bash
# Ubuntu
sudo apt update && sudo apt install tomcat10

# Or manual download
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.x/bin/apache-tomcat-10.1.x.tar.gz
tar -xzf apache-tomcat-10.1.x.tar.gz
```

### 3.2 Configure JVM Options
Edit `bin/setenv.sh` (create if not exists):
```bash
#!/bin/bash
# Heap sizing (adjust for your server)
export CATALINA_OPTS="-Xms2g -Xmx4g -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m"

# GC logging
export CATALINA_OPTS="$CATALINA_OPTS -Xlog:gc*:file=$CATALINA_BASE/logs/gc.log:time,uptime,level,tags:filecount=5,filesize=10m"

# Security
export CATALINA_OPTS="$CATALINA_OPTS -Djava.security.egd=file:/dev/./urandom"

# Encoding
export CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
```

### 3.3 Configure server.xml
```xml
<!-- conf/server.xml - HTTP connector -->
<Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="200" minSpareThreads="10"
           enableLookups="false" compression="on"
           compressableMimeType="text/html,text/xml,text/plain,text/css,application/json,application/javascript"
           URIEncoding="UTF-8" />

<!-- AJP (if behind Apache/Nginx) -->
<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />

<!-- Disable shutdown port in production or secure it -->
<Server port="-1" shutdown="SHUTDOWN">
```

### 3.4 Configure Context (Optional)
Create `conf/Catalina/localhost/CollegeApp.xml` for JNDI DataSource (alternative to DBUtil pool):
```xml
<Context>
    <Resource name="jdbc/CollegeDB"
              auth="Container"
              type="javax.sql.DataSource"
              maxTotal="20" maxIdle="5" maxWaitMillis="10000"
              username="college_app" password="strong-random-password"
              driverClassName="com.mysql.cj.jdbc.Driver"
              url="jdbc:mysql://localhost:3306/college_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTF-8"
              validationQuery="SELECT 1" testOnBorrow="true" />
</Context>
```
*Then update DBUtil to use JNDI lookup instead of HikariCP.*

---

## 4. Deploy WAR

### 4.1 Manual Deploy
```bash
# Stop Tomcat
sudo systemctl stop tomcat10

# Deploy
cp target/CollegeApp.war /var/lib/tomcat10/webapps/

# Or custom Tomcat
cp target/CollegeApp.war $CATALINA_HOME/webapps/

# Start Tomcat
sudo systemctl start tomcat10
```

### 4.2 Auto-Deploy (Development)
```bash
# Tomcat auto-deploys on startup; just ensure WAR is in webapps/ before start
```

### 4.3 Verify Deployment
```bash
# Check logs
tail -f /var/lib/tomcat10/logs/catalina.out

# Health check
curl http://localhost:8080/CollegeApp/health
# {"status":"UP",...}
```

---

## 5. Reverse Proxy (Nginx) — Recommended for Production

### 5.1 Install Nginx
```bash
sudo apt install nginx
```

### 5.2 Configure SSL (Let's Encrypt)
```bash
sudo certbot --nginx -d collegehub.yourdomain.com
```

### 5.3 Nginx Config
```nginx
# /etc/nginx/sites-available/collegehub
upstream tomcat {
    server localhost:8080;
    keepalive 32;
}

server {
    listen 80;
    server_name collegehub.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name collegehub.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/collegehub.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/collegehub.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Security headers (defense in depth)
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy strict-origin-when-cross-origin;
    add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; script-src 'self';";

    # Proxy to Tomcat
    location / {
        proxy_pass http://tomcat;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
    }

    # Static assets caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        proxy_pass http://tomcat;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Health check (no auth)
    location /CollegeApp/health {
        proxy_pass http://tomcat;
        access_log off;
    }
}
```

### 5.4 Enable & Test
```bash
sudo ln -s /etc/nginx/sites-available/collegehub /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 6. Systemd Service (If Manual Tomcat)

```ini
# /etc/systemd/system/tomcat10.service
[Unit]
Description=Apache Tomcat 10
After=network.target mysql.service

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=CATALINA_HOME=/opt/tomcat10
Environment=CATALINA_BASE=/opt/tomcat10
Environment=CATALINA_PID=/opt/tomcat10/temp/tomcat.pid
Environment='CATALINA_OPTS=-Xms2g -Xmx4g -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m'
ExecStart=/opt/tomcat10/bin/startup.sh
ExecStop=/opt/tomcat10/bin/shutdown.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable tomcat10
sudo systemctl start tomcat10
```

---

## 7. Environment-Specific Configuration

### 7.1 Development
```bash
DB_URL=jdbc:mysql://localhost:3306/college_db?...
DB_USER=root
DB_PASS=devpass
BCRYPT_COST=4  # Faster for dev
API_KEY=dev-key
```

### 7.2 Staging
```bash
DB_URL=jdbc:mysql://staging-db:3306/college_db?...
DB_USER=college_app
DB_PASS=${STAGING_DB_PASS}
BCRYPT_COST=10
API_KEY=${STAGING_API_KEY}
```

### 7.3 Production
```bash
DB_URL=jdbc:mysql://prod-db:3306/college_db?...
DB_USER=college_app
DB_PASS=${PROD_DB_PASS}  # From secrets manager
BCRYPT_COST=12
API_KEY=${PROD_API_KEY}
```

---

## 8. Monitoring & Health Checks

### 8.1 Health Endpoint
```bash
# Liveness (for Kubernetes)
curl -f http://localhost:8080/CollegeApp/health || exit 1

# Readiness (checks DB)
curl -f http://localhost:8080/CollegeApp/health | jq -e '.status=="UP"' || exit 1
```

### 8.2 Key Metrics to Monitor

| Metric | Source | Alert Threshold |
|--------|--------|-----------------|
| JVM Heap Usage | JMX/Prometheus | >85% for 5min |
| DB Pool Active | `/health` endpoint | >80% of max |
| DB Pool Waiting | `/health` endpoint | >0 for 1min |
| Request Latency (p95) | Nginx/APM | >2s |
| Error Rate | Nginx/APM | >1% |
| Disk Space | Node Exporter | <10% free |

### 8.3 Log Aggregation
```bash
# Tomcat logs
/var/lib/tomcat10/logs/catalina.out
/var/lib/tomcat10/logs/localhost_access_log.*.txt

# GC logs
/var/lib/tomcat10/logs/gc.log

# Application logs (SLF4J → stdout → systemd journal)
journalctl -u tomcat10 -f
```

---

## 9. Backup & Recovery

### 9.1 Database Backup
```bash
#!/bin/bash
# /usr/local/bin/backup-collegehub.sh
DATE=$(date +%F-%H%M)
mysqldump -u college_app -p${DB_PASS} --single-transaction --routines --triggers college_db \
  | gzip > /backups/college_db-${DATE}.sql.gz

# Retain 30 days
find /backups -name 'college_db-*.sql.gz' -mtime +30 -delete
```

```bash
# Cron: daily at 2 AM
0 2 * * * /usr/local/bin/backup-collegehub.sh
```

### 9.2 Restore
```bash
gunzip -c /backups/college_db-2024-01-15-0200.sql.gz | mysql -u college_app -p college_db
```

---

## 10. CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: 'temurin', java-version: '17' }
      - run: mvn clean package
      - uses: actions/upload-artifact@v4
        with: { name: war, path: target/CollegeApp.war }

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with: { name: war, path: target/ }
      - name: Deploy to Tomcat
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PROD_HOST }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            sudo systemctl stop tomcat10
            cp target/CollegeApp.war /var/lib/tomcat10/webapps/
            sudo systemctl start tomcat10
            sleep 10
            curl -f http://localhost:8080/CollegeApp/health
```

---

## 11. Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | MySQL connector not in WAR | Check `pom.xml` dependency scope (should be compile) |
| `Communications link failure` | DB host/port wrong | Verify `DB_URL`, firewall, MySQL bind-address |
| `Access denied for user` | Wrong credentials | Verify `DB_USER`/`DB_PASS`, MySQL grants |
| `Table 'college_db.users' doesn't exist` | Schema not applied | Run `college_db.sql` |
| `403 Forbidden on POST` | CSRF token missing | Ensure `${csrfField}` in form; check `SecurityFilter` |
| `Redirect loop on login` | AuthFilter misconfiguration | Check role mapping in `AuthFilter` |
| `OutOfMemoryError` | Heap too small | Increase `-Xmx` in `setenv.sh` |
| `Connection pool exhausted` | Leak / high load | Check `LeakDetectionThreshold`; increase pool size |

---

## 12. Security Hardening Checklist

- [ ] MySQL: `bind-address = 127.0.0.1` (or private IP only)
- [ ] MySQL: `require_secure_transport = ON` (enforce TLS)
- [ ] Tomcat: Remove default webapps (ROOT, docs, examples, manager, host-manager)
- [ ] Tomcat: Secure shutdown port (`port="-1"` or strong password)
- [ ] Tomcat: Disable directory listings (`listings="false"` in `web.xml`)
- [ ] Nginx: TLS 1.2+ only, strong ciphers, HSTS
- [ ] Nginx: Rate limiting on `/login`
- [ ] JVM: `-Djava.security.egd=file:/dev/./urandom`
- [ ] OS: Firewall (only 22, 80, 443 open)
- [ ] OS: Automatic security updates enabled
- [ ] Secrets: DB password, API key in vault (not env files)
- [ ] Backups: Tested restore procedure documented

---

*Deployment guide version 1.0 — update with each release.*
