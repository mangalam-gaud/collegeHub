<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Grievance Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Grievance> myGrievances = ViewHelper.<Grievance>list(request, "myGrievances");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= myGrievances.size() %></div><div class="lbl">Total Grievances</div></div>
  <div class="stat"><div class="num"><%= myGrievances.stream().filter(g -> "SUBMITTED".equals(g.getStatus()) || "ACKNOWLEDGED".equals(g.getStatus()) || "IN_PROGRESS".equals(g.getStatus())).count() %></div><div class="lbl">Open</div></div>
  <div class="stat"><div class="num"><%= myGrievances.stream().filter(g -> "RESOLVED".equals(g.getStatus()) || "CLOSED".equals(g.getStatus())).count() %></div><div class="lbl">Resolved</div></div>
</div>
<div class="card">
  <h2>My Grievances
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/grievance/new">+ New Grievance</a></h2>
  <% if (myGrievances.isEmpty()) { %><div class="empty">No grievances submitted yet.</div><% } %>
  <div class="table-wrap"><table>
    <tr><th data-sort>Subject</th><th data-sort>Category</th><th>Priority</th><th>Status</th><th>Date</th><th style="width:150px">Actions</th></tr>
    <% for (Grievance g : myGrievances) { %>
    <tr>
      <td><b><%= g.getSubject() %></b></td>
      <td><span class="badge badge-teacher"><%= g.getCategory() %></span></td>
      <td><span class="badge <%= "URGENT".equals(g.getPriority()) ? "badge-off" : ("HIGH".equals(g.getPriority()) ? "badge-teacher" : "badge-student") %>"><%= g.getPriority() %></span></td>
      <td><span class="badge <%= "RESOLVED".equals(g.getStatus()) || "CLOSED".equals(g.getStatus()) ? "badge-on" : ("IN_PROGRESS".equals(g.getStatus()) ? "badge-teacher" : "badge-off") %>"><%= g.getStatus() %></span></td>
      <td><%= g.getCreatedAt() %></td>
      <td><a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/grievance/detail?id=<%= g.getId() %>">View</a></td>
    </tr>
    <% } %>
    <% if (myGrievances.isEmpty()) { %><tr><td colspan="6" class="empty">No grievances submitted yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>