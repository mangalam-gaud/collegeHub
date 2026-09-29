<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.util.Map" %>
<% request.setAttribute("pageTitle", "My Marks"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Map<String, Object>> marks = (List<Map<String, Object>>) request.getAttribute("marks"); %>
<div class="card">
  <h2>Examination Results</h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Course</th><th data-sort>Exam</th><th data-sort>Marks</th><th data-sort>Percentage</th><th data-sort>Grade</th></tr>
    <% for (Map<String, Object> m : marks) {
        double pct = (Double) m.get("marks") * 100.0 / (Double) m.get("max");
        String grade = pct >= 90 ? "A+" : pct >= 80 ? "A" : pct >= 70 ? "B" : pct >= 60 ? "C" : pct >= 50 ? "D" : "F"; %>
    <tr>
      <td><b><%= m.get("code") %></b> — <%= m.get("title") %></td>
      <td><span class="badge badge-admin"><%= m.get("examType") %></span></td>
      <td><%= m.get("marks") %> / <%= m.get("max") %></td>
      <td data-pct="<%= Math.round(pct) %>"><%= Math.round(pct * 10.0) / 10.0 %>%</td>
      <td><span class="badge <%= pct >= 50 ? "badge-present" : "badge-absent" %>"><%= grade %></span></td>
    </tr>
    <% } %>
    <% if (marks.isEmpty()) { %><tr><td colspan="5" class="empty">No marks published yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
