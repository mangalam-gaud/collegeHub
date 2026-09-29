<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Leave Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LeaveType> leaveTypes = ViewHelper.<LeaveType>list(request, "leaveTypes");
List<LeaveRequest> myRequests = ViewHelper.<LeaveRequest>list(request, "myRequests");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= myRequests.size() %></div><div class="lbl">My Requests</div></div>
  <div class="stat"><div class="num"><%= myRequests.stream().filter(r -> "PENDING".equals(r.getStatus())).count() %></div><div class="lbl">Pending</div></div>
  <div class="stat"><div class="num"><%= myRequests.stream().filter(r -> "APPROVED".equals(r.getStatus())).count() %></div><div class="lbl">Approved</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>My Leave Requests
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/leave/new-request">+ New Request</a></h2>
    <% if (myRequests.isEmpty()) { %><div class="empty">No leave requests yet.</div><% } %>
    <div class="table-wrap"><table>
      <tr><th data-sort>Type</th><th data-sort>From</th><th data-sort>To</th><th>Days</th><th>Status</th><th style="width:150px">Actions</th></tr>
      <% for (LeaveRequest lr : myRequests) { %>
      <tr>
        <td><%= lr.getLeaveTypeName() %></td>
        <td><%= lr.getStartDate() %></td>
        <td><%= lr.getEndDate() %></td>
        <td><%= lr.getTotalDays() %></td>
        <td><span class="badge <%= "PENDING".equals(lr.getStatus()) ? "badge-teacher" : ("APPROVED".equals(lr.getStatus()) ? "badge-on" : "badge-off") %>"><%= lr.getStatus() %></span></td>
        <td><a class="btn btn-outline btn-sm" href="#">View</a></td>
      </tr>
      <% } %>
      <% if (myRequests.isEmpty()) { %><tr><td colspan="6" class="empty">No requests yet.</td></tr><% } %>
    </table></div>
  </div>
  <div class="card">
    <h2>Leave Types</h2>
    <div class="table-wrap"><table>
      <tr><th>Type</th><th>Max Days/Year</th><th>Requires Approval</th></tr>
      <% for (LeaveType lt : leaveTypes) { %>
      <tr>
        <td><b><%= lt.getName() %></b></td>
        <td><%= lt.getMaxDaysPerYear() %></td>
        <td><%= lt.isRequiresApproval() ? "Yes" : "No" %></td>
      </tr>
      <% } %>
    </table></div>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>