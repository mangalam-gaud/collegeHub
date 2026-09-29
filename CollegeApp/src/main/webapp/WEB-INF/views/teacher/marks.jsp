<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, java.util.Map" %>
<%
request.setAttribute("pageTitle", "Enter Marks");
Course course = (Course) request.getAttribute("course");
List<Map<String, String>> students = (List<Map<String, String>>) request.getAttribute("students");
%>
<%@ include file="../layout/top.jsp" %>
<% if ("1".equals(request.getParameter("saved"))) { %><div class="alert alert-success">Marks saved successfully.</div><% } %>
<div class="card">
  <h2>Marks — <%= course.getCode() %> : <%= course.getTitle() %>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/teacher/courses">← Back</a></h2>
  <% if (students.isEmpty()) { %><div class="empty">No students enrolled in this course.</div><% } %>
  <form method="post" action="${pageContext.request.contextPath}/teacher/marks-save">
    ${csrfField}
    <input type="hidden" name="courseId" value="<%= course.getId() %>">
    <div class="form-grid" style="max-width:520px;margin-bottom:16px">
      <div class="field"><label>Exam Type</label>
        <select name="examType">
          <option value="INTERNAL">Internal</option>
          <option value="MIDTERM">Midterm</option>
          <option value="FINAL">Final</option>
        </select></div>
      <div class="field"><label>Max Marks</label>
        <input type="number" name="maxMarks" value="100" min="1" step="1"></div>
    </div>
    <div class="table-wrap"><table>
      <tr><th>Student</th><th style="width:180px">Marks Obtained</th></tr>
      <% for (Map<String, String> s : students) { %>
      <tr>
        <td><b><%= s.get("name") %></b> <span style="color:var(--gray-400)">(@<%= s.get("username") %>)</span></td>
        <td><input type="hidden" name="studentIds" value="<%= s.get("id") %>">
            <input type="number" name="marks_<%= s.get("id") %>" min="0" step="0.5" placeholder="—"></td>
      </tr>
      <% } %>
    </table></div>
    <% if (!students.isEmpty()) { %>
    <div class="form-actions"><button class="btn btn-primary">Save Marks</button></div>
    <% } %>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
