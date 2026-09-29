<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*, java.util.Calendar, com.college.model.*, java.util.Map" %>
<%
request.setAttribute("pageTitle", "Mark Attendance");
Course course = (Course) request.getAttribute("course");
List<Map<String, String>> students = (List<Map<String, String>>) request.getAttribute("students");
String today = new SimpleDateFormat("yyyy-MM-dd").format(Calendar.getInstance().getTime());
%>
<%@ include file="../layout/top.jsp" %>
<% if ("1".equals(request.getParameter("saved"))) { %><div class="alert alert-success">Attendance saved successfully.</div><% } %>
<div class="card">
  <h2>Attendance — <%= course.getCode() %> : <%= course.getTitle() %>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/teacher/courses">← Back</a></h2>
  <% if (students.isEmpty()) { %><div class="empty">No students enrolled in this course.</div><% } %>
  <form method="post" action="${pageContext.request.contextPath}/teacher/attendance-save">
    ${csrfField}
    <input type="hidden" name="courseId" value="<%= course.getId() %>">
    <div class="field" style="max-width:220px;margin-bottom:16px"><label>Date</label>
      <input type="date" name="date" value="<%= today %>" required></div>
    <div class="table-wrap"><table>
      <tr><th>Student</th><th>Status</th></tr>
      <% for (Map<String, String> s : students) { %>
      <tr>
        <td><b><%= s.get("name") %></b> <span style="color:var(--gray-400)">(@<%= s.get("username") %>)</span></td>
        <td>
          <input type="hidden" name="studentIds" value="<%= s.get("id") %>">
          <label class="pill" style="margin-right:10px"><input type="radio" name="status_<%= s.get("id") %>" value="PRESENT" checked> Present</label>
          <label class="pill"><input type="radio" name="status_<%= s.get("id") %>" value="ABSENT"> Absent</label>
        </td>
      </tr>
      <% } %>
    </table></div>
    <% if (!students.isEmpty()) { %>
    <div class="form-actions"><button class="btn btn-primary">Save Attendance</button></div>
    <% } %>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
