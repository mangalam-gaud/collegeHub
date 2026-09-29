<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Exams"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Exam> exams = ViewHelper.<Exam>list(request, "exams");
String sem = request.getParameter("examSem");
%>
<div class="card">
  <h2>Exams
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/academic/exam-form">+ Schedule Exam</a></h2>
  <form method="get" class="form-grid" style="margin-bottom:18px">
    <div class="field">
      <label for="examSem">Semester ID</label>
      <input type="text" id="examSem" name="examSem" value="<%= sem == null ? "" : sem %>" placeholder="e.g. 1">
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <button type="submit" class="btn btn-primary" style="width:100%">Filter by Semester</button>
    </div>
  </form>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Exam</th><th data-sort>Type</th><th data-sort>Course</th>
      <th data-sort>Date</th><th data-sort>Time</th><th data-sort>Room</th>
      <th data-sort>Marks</th><th>Status</th><th style="width:190px">Actions</th>
    </tr>
    <% for (Exam e : exams) { %>
    <tr>
      <td><b><%= e.getName() %></b></td>
      <td><%= e.getExamType() %></td>
      <td><%= e.getCourseCode() %> <%= e.getCourseTitle() %></td>
      <td><%= e.getExamDate() %></td>
      <td><%= e.getStartTime() %> – <%= e.getEndTime() %></td>
      <td><%= e.getRoom() != null ? e.getRoom() : "—" %></td>
      <td><%= e.getMaxMarks() %> / pass <%= e.getPassingMarks() %></td>
      <td><span class="badge <%= "COMPLETED".equalsIgnoreCase(String.valueOf(e.getStatus())) ? "badge-off"
              : ("SCHEDULED".equalsIgnoreCase(String.valueOf(e.getStatus())) ? "badge-on" : "badge-teacher") %>"><%= e.getStatus() %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/exam-results?examId=<%= e.getId() %>">Results</a>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/exam-form?edit=<%= e.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (exams.isEmpty()) { %>
    <tr><td colspan="9" class="empty">No exams found. <%= sem == null || sem.isEmpty() ? "Enter a Semester ID to filter." : "" %></td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
