<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Admin Dashboard"); %>
<%@ include file="../layout/top.jsp" %>

<div class="stats">
  <div class="stat"><div class="num"><%= request.getAttribute("studentCount") %></div><div class="lbl">Students</div></div>
  <div class="stat"><div class="num"><%= request.getAttribute("teacherCount") %></div><div class="lbl">Teachers</div></div>
  <div class="stat"><div class="num"><%= request.getAttribute("courseCount") %></div><div class="lbl">Courses</div></div>
</div>

<div class="grid2">
  <div class="card">
    <h2>Quick Actions</h2>
    <div style="display:flex;gap:10px;flex-wrap:wrap">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/user-form?role=STUDENT">+ Add Student</a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/user-form?role=TEACHER">+ Add Teacher</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/course-form">+ Add Course</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/notices">Post Notice</a>
    </div>
  </div>
  <div class="card">
    <h2>Recent Notices</h2>
    <% List<Notice> notices = ViewHelper.<Notice>list(request, "notices");
       if (notices.isEmpty()) { %><div class="empty">No notices yet.</div><% }
       int i = 0;
       for (Notice n : notices) { if (i++ >= 4) break; %>
      <div class="notice" style="margin-bottom:10px">
        <h3><%= n.getTitle() %></h3>
        <div class="meta"><%= n.getCreatedAt() %> • <%= n.getAuthorName() %></div>
      </div>
    <% } %>
  </div>
</div>

<%@ include file="../layout/bottom.jsp" %>
