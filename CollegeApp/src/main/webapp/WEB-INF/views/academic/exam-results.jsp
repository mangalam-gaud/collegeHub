<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Exam Results"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<ExamResult> results = ViewHelper.<ExamResult>list(request, "results");
Exam exam = (Exam) request.getAttribute("exam");
String examId = request.getParameter("examId");
%>
<div class="card">
  <h2>Exam Results<% if (exam != null) { %> — <%= exam.getName() %><% } %></h2>
  <form method="get" class="form-grid" style="margin-bottom:18px">
    <div class="field">
      <label for="examId">Exam ID</label>
      <input type="text" id="examId" name="examId" value="<%= examId == null ? "" : examId %>" placeholder="e.g. 1">
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <button type="submit" class="btn btn-primary" style="width:100%">Load Results</button>
    </div>
  </form>
  <div class="table-wrap"><table>
    <tr><th data-sort>Student</th><th data-sort>Username</th><th data-sort>Obtained</th><th data-sort>Max</th><th data-sort>%</th><th>Result</th><th>Remarks</th></tr>
    <% for (ExamResult r : results) { %>
    <tr>
      <td><b><%= r.getStudentName() %></b></td>
      <td><%= r.getStudentUsername() %></td>
      <td><%= r.getMarksObtained() %></td>
      <td><%= r.getMaxMarks() %></td>
      <td><%= String.format("%.2f", r.getPercentage()) %>%</td>
      <td><span class="badge <%= "PASS".equalsIgnoreCase(String.valueOf(r.getStatus())) ? "badge-on"
              : ("FAIL".equalsIgnoreCase(String.valueOf(r.getStatus())) ? "badge-off" : "badge-teacher") %>"><%= r.getStatus() %></span></td>
      <td><%= r.getRemarks() != null ? r.getRemarks() : "—" %></td>
    </tr>
    <% } %>
    <% if (results.isEmpty()) { %>
    <tr><td colspan="7" class="empty">No results found. <%= examId == null || examId.isEmpty() ? "Enter an Exam ID above." : "" %></td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
