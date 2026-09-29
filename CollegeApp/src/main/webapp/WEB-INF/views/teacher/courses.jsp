<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "My Courses"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Course> courses = ViewHelper.<Course>list(request, "courses"); %>
<div class="card">
  <div class="table-wrap"><table>
    <tr><th>Code</th><th>Title</th><th>Credits</th><th>Semester</th><th>Actions</th></tr>
    <% for (Course c : courses) { %>
    <tr>
      <td><b><%= c.getCode() %></b></td>
      <td><%= c.getTitle() %></td>
      <td><%= c.getCredits() %></td>
      <td><%= c.getSemester() %></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/teacher/attendance?courseId=<%= c.getId() %>">📅 Attendance</a>
        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/teacher/marks?courseId=<%= c.getId() %>">🎯 Marks</a>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/teacher/export-attendance?courseId=<%= c.getId() %>">⬇ CSV</a>
      </td>
    </tr>
    <% } %>
    <% if (courses.isEmpty()) { %><tr><td colspan="5" class="empty">No courses assigned to you.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
