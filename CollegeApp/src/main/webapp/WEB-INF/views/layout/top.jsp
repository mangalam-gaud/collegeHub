<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.college.model.User" %>
<%@ page import="com.college.filter.SecurityFilter" %>
<%@ page import="com.college.servlet.LoginServlet" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>
<%
User me = (User) session.getAttribute("user");
String role = me.getRole();
String ctx = request.getContextPath();
String cur = request.getRequestURI().substring(ctx.length());
String csrf = SecurityFilter.token(session);
String csrfField = "<input type=\"hidden\" name=\"csrf\" value=\"" + csrf + "\"/>";
request.setAttribute("csrfField", csrfField);
request.setAttribute("ctx", ctx);
// `styleVersion` (stylesheet cache-busting token) is published as a request
// attribute by SecurityFilter.

// "icon|Label|/path" - the path is always context-relative, never absolute.
List<String> adminNav = Arrays.asList(
    "🏠|Dashboard|/admin/dashboard",
    "👥|Users|/admin/users",
    "📚|Courses|/admin/courses",
    "📢|Notices|/admin/notices",
    "🏢|Departments|/admin/departments",
    "🎓|Programs|/admin/programs",
    "📅|Academic|/academic/dashboard",
    "💰|Fees|/fee/dashboard",
    "📖|Library|/library/dashboard",
    "🏠|Hostel|/hostel/dashboard",
    "🚌|Transport|/transport/dashboard",
    "📅|Leave|/leave/dashboard",
    "🎪|Events|/events/list",
    "💬|Messages|/messages/inbox"
);

List<String> teacherNav = Arrays.asList(
    "🏠|Dashboard|/teacher/dashboard",
    "📚|My Courses|/teacher/courses",
    "📋|Attendance|/teacher/attendance",
    "🎯|Marks|/teacher/marks",
    "📢|Notices|/teacher/notices",
    "📅|Academic|/academic/dashboard",
    "🕐|Time Slots|/academic/timetable-slots",
    "📝|Exams|/academic/exams",
    "📅|My Leave|/leave/my-requests",
    "💬|Messages|/messages/inbox"
);

List<String> studentNav = Arrays.asList(
    "🏠|Dashboard|/student/dashboard",
    "📚|Courses|/student/courses",
    "📋|Attendance|/student/attendance",
    "🎯|Marks|/student/marks",
    "💰|My Fees|/fee/my-fees",
    "📖|My Books|/library/my-issues",
    "📢|Notices|/student/notices",
    "🎪|Events|/events/list",
    "📝|Grievance|/grievance/new",
    "📅|Apply Leave|/leave/new-request",
    "💬|Messages|/messages/inbox",
    "👤|Profile|/student/profile"
);

List<String> accountantNav = Arrays.asList(
    "🏠|Dashboard|/fee/dashboard",
    "💳|My Fee Status|/fee/my-fees",
    "📅|Leave|/leave/dashboard",
    "💬|Messages|/messages/inbox",
    "🎪|Events|/events/list"
);

List<String> librarianNav = Arrays.asList(
    "🏠|Dashboard|/library/dashboard",
    "📖|Books|/library/books",
    "📋|Issues|/library/issues",
    "📅|Leave|/leave/dashboard",
    "💬|Messages|/messages/inbox"
);

List<String> hostelWardenNav = Arrays.asList(
    "🏠|Dashboard|/hostel/dashboard",
    "🏢|Hostels|/hostel/hostels",
    "🚪|Rooms|/hostel/rooms",
    "🛏️|Allocations|/hostel/allocations",
    "📅|Leave|/leave/dashboard",
    "💬|Messages|/messages/inbox"
);

List<String> transportManagerNav = Arrays.asList(
    "🏠|Dashboard|/transport/dashboard",
    "🚌|Routes|/transport/routes",
    "📋|Bookings|/transport/bookings",
    "📅|Leave|/leave/dashboard",
    "💬|Messages|/messages/inbox"
);

List<String> nav;
if ("ADMIN".equals(role))            nav = adminNav;
else if ("TEACHER".equals(role))      nav = teacherNav;
else if ("ACCOUNTANT".equals(role))   nav = accountantNav;
else if ("LIBRARIAN".equals(role))    nav = librarianNav;
else if ("HOSTEL_WARDEN".equals(role))nav = hostelWardenNav;
else if ("TRANSPORT_MANAGER".equals(role)) nav = transportManagerNav;
else                                  nav = studentNav;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Dashboard" %> — Mangaud CollegeHub</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${styleVersion}" id="appStylesheet">
  <link rel="icon" href="${pageContext.request.contextPath}/img/logo-mark.svg" type="image/svg+xml">
  <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/img/logo-mark.svg">
</head>
<body>
<div class="shell">
  <aside class="sidebar" id="sidebar">
    <div class="brand">
      <a href="<%= ctx %>/<%= LoginServlet.landingPageFor(role) %>" class="brand-link">
        <img class="brand-mark" src="<%= ctx %>/img/logo-mark.svg" alt="" width="34" height="34">
        <span class="txt">Mangaud <span style="color:var(--brand-gold-400)">CollegeHub</span></span>
      </a>
    </div>
    <nav>
      <%
        for (String item : nav) {
            String[] parts = item.split("\\|");
            String icon = parts[0];
            String label = parts[1];
            String path = parts[2];
            boolean active = cur.equals(path) || cur.startsWith(path + "/")
                             || (cur.equals("/") && path.endsWith("/dashboard"));
      %>
      <a href="<%= ctx %><%= path %>" class="<%= active ? "active" : "" %>"
         <%= active ? "aria-current=\"page\"" : "" %>>
        <span class="ico" aria-hidden="true"><%= icon %></span> <span class="txt"><%= label %></span>
      </a>
      <% } %>
    </nav>
    <div class="footer">
      <a href="<%= ctx %>/logout" style="color:#f87171" title="Logout">
        <span class="ico" aria-hidden="true">⎋</span> <span class="txt">Logout</span>
      </a>
    </div>
  </aside>
  <main class="main">
    <div class="topbar">
      <div style="display:flex;align-items:center;gap:12px;min-width:0">
        <button class="icon-btn hamburger" aria-label="Toggle navigation">☰</button>
        <h1><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Dashboard" %></h1>
      </div>
      <div class="topbar-meta">
        <a class="icon-btn" href="<%= ctx %>/messages/notifications" aria-label="Notifications" title="Notifications">🔔</a>
        <span class="clock" aria-live="off">–</span>
        <button class="icon-btn" data-theme-toggle aria-label="Toggle dark mode" title="Toggle dark mode">◐</button>
        <div class="userchip">
          <div class="avatar"><%= me.getFullName() != null && me.getFullName().length() > 0
                ? me.getFullName().substring(0,1).toUpperCase() : "U" %></div>
          <div>
            <div class="name"><%= me.getFullName() %></div>
            <div class="role"><%= me.getRole() %></div>
          </div>
        </div>
      </div>
    </div>
