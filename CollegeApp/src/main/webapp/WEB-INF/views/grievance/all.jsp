<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "All Grievances"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Grievance> items = ViewHelper.<Grievance>list(request, "grievances");
String status = ViewHelper.str(request, "status");
String category = ViewHelper.str(request, "category");
%>
<div class="card">
  <h2>All Grievances</h2>
  <form method="get" style="display:flex;gap:10px;margin-bottom:18px;flex-wrap:wrap;align-items:center">
    <select name="status" style="width:auto" aria-label="Filter by status">
      <option value="">All Statuses</option>
      <option value="OPEN"       <%= "OPEN".equals(status)       ? "selected" : "" %>>Open</option>
      <option value="IN_PROGRESS"<%= "IN_PROGRESS".equals(status)? "selected" : "" %>>In Progress</option>
      <option value="RESOLVED"   <%= "RESOLVED".equals(status)   ? "selected" : "" %>>Resolved</option>
      <option value="REJECTED"   <%= "REJECTED".equals(status)   ? "selected" : "" %>>Rejected</option>
    </select>
    <select name="category" style="width:auto" aria-label="Filter by category">
      <option value="">All Categories</option>
      <option value="ACADEMIC"  <%= "ACADEMIC".equals(category)  ? "selected" : "" %>>Academic</option>
      <option value="INFRASTRUCTURE" <%= "INFRASTRUCTURE".equals(category) ? "selected" : "" %>>Infrastructure</option>
      <option value="HOSTEL"    <%= "HOSTEL".equals(category)    ? "selected" : "" %>>Hostel</option>
      <option value="TRANSPORT" <%= "TRANSPORT".equals(category) ? "selected" : "" %>>Transport</option>
      <option value="ADMIN"     <%= "ADMIN".equals(category)     ? "selected" : "" %>>Admin</option>
      <option value="OTHER"     <%= "OTHER".equals(category)     ? "selected" : "" %>>Other</option>
    </select>
    <button type="submit" class="btn btn-primary">Filter</button>
    <a class="btn btn-outline" href="${pageContext.request.contextPath}/grievance/all">Clear</a>
  </form>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Student</th><th data-sort>Subject</th><th data-sort>Category</th><th data-sort>Priority</th>
      <th data-sort>Status</th><th data-sort>Assigned</th><th data-sort>Raised</th><th style="width:110px">Actions</th>
    </tr>
    <% for (Grievance g : items) { %>
    <tr>
      <td><b><%= g.getStudentName() %></b><br><small><%= g.getStudentUsername() %></small></td>
      <td><%= g.getSubject() %></td>
      <td><%= g.getCategory() %></td>
      <td><span class="badge <%= "HIGH".equalsIgnoreCase(String.valueOf(g.getPriority())) ? "badge-off"
              : ("LOW".equalsIgnoreCase(String.valueOf(g.getPriority())) ? "badge-teacher" : "badge-on") %>"><%= g.getPriority() %></span></td>
      <td><span class="badge <%= "RESOLVED".equalsIgnoreCase(String.valueOf(g.getStatus())) ? "badge-on"
              : ("REJECTED".equalsIgnoreCase(String.valueOf(g.getStatus())) ? "badge-off" : "badge-teacher") %>"><%= g.getStatus() %></span></td>
      <td><small><%= g.getAssignedToName() != null ? g.getAssignedToName() : "Unassigned" %></small></td>
      <td><small><%= g.getCreatedAt() %></small></td>
      <td><a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/grievance/detail?id=<%= g.getId() %>">Open</a></td>
    </tr>
    <% } %>
    <% if (items.isEmpty()) { %><tr><td colspan="8" class="empty">No grievances found.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
