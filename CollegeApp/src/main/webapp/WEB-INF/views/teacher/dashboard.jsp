<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Teacher Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Course> courses = ViewHelper.<Course>list(request, "courses");
List<Notice> notices = ViewHelper.<Notice>list(request, "notices");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= courses.size() %></div><div class="lbl">My Courses</div></div>
  <div class="stat"><div class="num"><%= notices.size() %></div><div class="lbl">Active Notices</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>My Courses</h2>
    <% if (courses.isEmpty()) { %><div class="empty">No courses assigned yet. Contact admin.</div><% } %>
    <div class="table-wrap"><table>
      <tr><th>Code</th><th>Title</th><th>Sem</th><th>Actions</th></tr>
      <% for (Course c : courses) { %>
      <tr>
        <td><b><%= c.getCode() %></b></td>
        <td><%= c.getTitle() %></td>
        <td><%= c.getSemester() %></td>
        <td>
          <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/teacher/attendance?courseId=<%= c.getId() %>">Attendance</a>
          <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/teacher/marks?courseId=<%= c.getId() %>">Marks</a>
        </td>
      </tr>
      <% } %>
    </table></div>
  </div>
  <div class="card">
    <h2>Recent Notices</h2>
    <% for (Notice n : notices) { if (n == notices.get(0)) {} %>
      <div class="notice" style="margin-bottom:10px">
        <h3><%= n.getTitle() %></h3>
        <div class="meta"><%= n.getCreatedAt() %></div>
      </div>
    <% } %>
    <% if (notices.isEmpty()) { %><div class="empty">No notices.</div><% } %>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>
