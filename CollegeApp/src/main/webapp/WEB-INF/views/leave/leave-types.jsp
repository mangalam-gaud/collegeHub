<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Leave Types"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LeaveType> types = ViewHelper.<LeaveType>list(request, "leaveTypes");
%>
<div class="card">
  <h2>Leave Types</h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Name</th><th data-sort>Code</th><th data-sort>Max Days / Year</th><th>Description</th></tr>
    <% for (LeaveType t : types) { %>
    <tr>
      <td><b><%= t.getName() %></b></td>
      <td><%= t.getCode() %></td>
      <td><%= t.getMaxDaysPerYear() %></td>
      <td><small><%= t.getDescription() != null ? t.getDescription() : "—" %></small></td>
    </tr>
    <% } %>
    <% if (types.isEmpty()) { %><tr><td colspan="4" class="empty">No leave types configured.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
