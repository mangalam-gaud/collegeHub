<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.util.Map" %>
<% request.setAttribute("pageTitle", "My Attendance"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Map<String, Object>> summary = (List<Map<String, Object>>) request.getAttribute("summary"); %>
<div class="card">
  <h2>Attendance Summary</h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Course</th><th data-sort>Attended</th><th data-sort>Total</th><th data-sort>Percentage</th><th>Status</th></tr>
    <% for (Map<String, Object> a : summary) { %>
    <tr>
      <td><b><%= a.get("code") %></b> — <%= a.get("title") %></td>
      <td><%= a.get("attended") %></td>
      <td><%= a.get("total") %></td>
      <td data-pct="<%= a.get("pct") %>"><%= a.get("pct") %>%</td>
      <td><span class="badge <%= (Double) a.get("pct") >= 75 ? "badge-present" : "badge-absent" %>">
          <%= (Double) a.get("pct") >= 75 ? "Good (≥75%)" : "Low (<75%)" %></span></td>
    </tr>
    <% } %>
    <% if (summary.isEmpty()) { %><tr><td colspan="5" class="empty">No attendance recorded yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
