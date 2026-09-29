<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "My Grievances"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Grievance> items = ViewHelper.<Grievance>list(request, "grievances");
%>
<div class="card">
  <h2>My Grievances
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/grievance/new">+ Raise Grievance</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Subject</th><th data-sort>Category</th><th data-sort>Priority</th>
      <th data-sort>Status</th><th data-sort>Raised</th><th data-sort>Assigned To</th><th>Resolution</th>
    </tr>
    <% for (Grievance g : items) { %>
    <tr>
      <td><b><%= g.getSubject() %></b></td>
      <td><%= g.getCategory() %></td>
      <td><span class="badge <%= "HIGH".equalsIgnoreCase(String.valueOf(g.getPriority())) ? "badge-off"
              : ("LOW".equalsIgnoreCase(String.valueOf(g.getPriority())) ? "badge-teacher" : "badge-on") %>"><%= g.getPriority() %></span></td>
      <td><span class="badge <%= "RESOLVED".equalsIgnoreCase(String.valueOf(g.getStatus())) ? "badge-on"
              : ("REJECTED".equalsIgnoreCase(String.valueOf(g.getStatus())) ? "badge-off" : "badge-teacher") %>"><%= g.getStatus() %></span></td>
      <td><small><%= g.getCreatedAt() %></small></td>
      <td><small><%= g.getAssignedToName() != null ? g.getAssignedToName() : "Unassigned" %></small></td>
      <td><small><%= g.getResolution() != null ? g.getResolution() : "—" %></small></td>
    </tr>
    <% } %>
    <% if (items.isEmpty()) { %><tr><td colspan="7" class="empty">You have not raised any grievances.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
