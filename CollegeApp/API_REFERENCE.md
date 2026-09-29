# CollegeHub — API Reference

## Overview

RESTful API endpoints for programmatic access to CollegeHub data. All endpoints require API key authentication via `X-API-Key` header.

**Base URL**: `https://your-domain.com/CollegeApp/api`

**Authentication**: Header `X-API-Key: <your-api-key>`

**Content-Type**: `application/json`

**Rate Limit**: 100 requests/minute per API key

---

## Endpoints

### 1. Health Check

**GET** `/health`

Public endpoint — no authentication required.

#### Response 200 (Healthy)
```json
{
  "status": "UP",
  "database": {
    "connected": true,
    "pool": {
      "active": 3,
      "idle": 2,
      "total": 5,
      "waiting": 0
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### Response 503 (Unhealthy)
```json
{
  "status": "DOWN",
  "database": {
    "connected": false,
    "pool": {
      "active": 0,
      "idle": 0,
      "total": 0,
      "waiting": 0
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### 2. System Statistics

**GET** `/api/stats`

Returns aggregate counts for dashboard widgets.

#### Response 200
```json
{
  "students": 1250,
  "teachers": 85,
  "admins": 3,
  "courses": 240,
  "enrollments": 15420,
  "notices": 47
}
```

---

### 3. Users

**GET** `/api/users`

Paginated, filterable user listing.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `role` | string | - | Filter by role: `ADMIN`, `TEACHER`, `STUDENT` |
| `q` | string | - | Search query (name, username, email) |
| `page` | integer | 1 | Page number (1-indexed) |
| `size` | integer | 20 | Page size (max 100) |

#### Example Request
```
GET /api/users?role=STUDENT&q=john&page=1&size=10
X-API-Key: your-api-key
```

#### Response 200
```json
{
  "users": [
    {
      "id": 42,
      "username": "john.doe",
      "email": "john.doe@student.edu",
      "role": "STUDENT",
      "fullName": "John Doe",
      "phone": "+1-555-0123",
      "gender": "MALE",
      "dob": "2002-03-15",
      "address": "123 Campus Dr, City, State",
      "active": true
    }
  ],
  "page": 1,
  "size": 10
}
```

#### Error Responses

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `Invalid page/size` | Page < 1 or size > 100 |
| 401 | `Unauthorized` | Missing or invalid API key |

---

### 4. Courses

**GET** `/api/courses`

Returns all courses with teacher information.

#### Response 200
```json
{
  "courses": [
    {
      "id": 1,
      "code": "CS101",
      "title": "Introduction to Computer Science",
      "credits": 3,
      "semester": 1,
      "teacherId": 5,
      "teacherName": "Dr. Jane Smith"
    },
    {
      "id": 2,
      "code": "MATH201",
      "title": "Calculus II",
      "credits": 4,
      "semester": 2,
      "teacherId": null,
      "teacherName": null
    }
  ]
}
```

---

## Data Models

### User
```json
{
  "id": "integer",
  "username": "string (unique, max 50)",
  "email": "string (unique, max 100)",
  "role": "string (ADMIN|TEACHER|STUDENT)",
  "fullName": "string (max 100)",
  "phone": "string (max 20, nullable)",
  "gender": "string (max 10, nullable)",
  "dob": "string (ISO date YYYY-MM-DD, nullable)",
  "address": "string (max 255, nullable)",
  "active": "boolean"
}
```

### Course
```json
{
  "id": "integer",
  "code": "string (unique, max 20)",
  "title": "string (max 100)",
  "credits": "integer (default 3)",
  "semester": "integer (default 1)",
  "teacherId": "integer (nullable, FK to users.id)",
  "teacherName": "string (nullable, denormalized)"
}
```

### Notice
```json
{
  "id": "integer",
  "title": "string (max 150)",
  "body": "string (text)",
  "audience": "string (ALL|STUDENT|TEACHER)",
  "authorName": "string",
  "createdAt": "string (ISO date YYYY-MM-DD)"
}
```

### Enrollment
```json
{
  "id": "integer",
  "studentId": "integer",
  "courseId": "integer",
  "enrolledAt": "string (ISO timestamp)"
}
```

### Attendance
```json
{
  "id": "integer",
  "studentId": "integer",
  "courseId": "integer",
  "date": "string (ISO date YYYY-MM-DD)",
  "status": "string (PRESENT|ABSENT)",
  "markedBy": "integer (FK to users.id)"
}
```

### Marks
```json
{
  "id": "integer",
  "studentId": "integer",
  "courseId": "integer",
  "examType": "string (MIDTERM|FINAL|INTERNAL)",
  "marksObtained": "decimal(5,2)",
  "maxMarks": "decimal(5,2) (default 100)",
  "enteredBy": "integer (FK to users.id)"
}
```

---

## Error Format

All error responses follow RFC 7807 Problem Details:

```json
{
  "type": "https://collegehub.example.com/errors/unauthorized",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Valid X-API-Key header required",
  "instance": "/api/users"
}
```

### Common Error Types

| Status | Type | Title | When |
|--------|------|-------|------|
| 400 | `invalid-request` | Bad Request | Malformed query params |
| 401 | `unauthorized` | Unauthorized | Missing/invalid API key |
| 403 | `forbidden` | Forbidden | Valid key but insufficient scope (future) |
| 404 | `not-found` | Not Found | Unknown endpoint |
| 429 | `rate-limited` | Too Many Requests | Rate limit exceeded |
| 500 | `internal-error` | Internal Server Error | Unexpected exception |
| 503 | `service-unavailable` | Service Unavailable | Database down |

---

## Pagination

List endpoints support cursor-based pagination via `page` and `size` parameters.

**Response includes:**
```json
{
  "users": [...],
  "page": 1,
  "size": 20
}
```

**Total count**: Not included (expensive on large tables). Use `page=1,size=1` + check empty array to detect end.

---

## Filtering & Search

| Endpoint | Filterable Fields |
|----------|-------------------|
| `/api/users` | `role` (exact), `q` (fuzzy: name, username, email) |
| `/api/courses` | None (returns all) |

**Search behavior**: `q` parameter uses SQL `LIKE` with wildcards, escaped for injection safety.

---

## Rate Limiting

- **Limit**: 100 requests/minute per API key
- **Headers returned**:
  - `X-RateLimit-Limit`: 100
  - `X-RateLimit-Remaining`: requests left in window
  - `X-RateLimit-Reset`: Unix timestamp when window resets
- **Exceeded**: Returns 429 with `Retry-After` header (seconds)

---

## Versioning

Current version: **v1** (implicit in `/api/` path)

Future versions will use `/api/v2/` path. Breaking changes only in new versions.

---

## Webhooks (Future)

Planned webhook events for real-time integration:

| Event | Payload |
|-------|---------|
| `user.created` | User object |
| `user.updated` | User object + changed fields |
| `enrollment.created` | Enrollment object |
| `attendance.marked` | Attendance object |
| `marks.entered` | Marks object |
| `notice.posted` | Notice object |

---

## SDKs & Examples

### cURL
```bash
# Health check
curl https://collegehub.example.com/CollegeApp/api/health

# Get stats (with API key)
curl -H "X-API-Key: your-key" https://collegehub.example.com/CollegeApp/api/stats

# Search students
curl -H "X-API-Key: your-key" "https://collegehub.example.com/CollegeApp/api/users?role=STUDENT&q=john&page=1&size=5"
```

### JavaScript (Fetch)
```javascript
const API_BASE = '/CollegeApp/api';
const API_KEY = 'your-api-key';

async function apiGet(path, params = {}) {
  const url = new URL(API_BASE + path, window.location.origin);
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));

  const resp = await fetch(url, {
    headers: { 'X-API-Key': API_KEY, 'Accept': 'application/json' }
  });

  if (!resp.ok) {
    const err = await resp.json();
    throw new Error(`${resp.status}: ${err.title} - ${err.detail}`);
  }
  return resp.json();
}

// Usage
const stats = await apiGet('/stats');
const students = await apiGet('/users', { role: 'STUDENT', q: 'john', page: 1, size: 10 });
```

### Python (requests)
```python
import requests

BASE = 'https://collegehub.example.com/CollegeApp/api'
HEADERS = {'X-API-Key': 'your-api-key', 'Accept': 'application/json'}

def api_get(path, params=None):
    resp = requests.get(f'{BASE}{path}', headers=HEADERS, params=params)
    resp.raise_for_status()
    return resp.json()

# Usage
stats = api_get('/stats')
students = api_get('/users', {'role': 'STUDENT', 'q': 'john', 'page': 1, 'size': 10})
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01-15 | Initial release: health, stats, users, courses |

---

*API is under active development — expect additions. Subscribe to release notes for updates.*