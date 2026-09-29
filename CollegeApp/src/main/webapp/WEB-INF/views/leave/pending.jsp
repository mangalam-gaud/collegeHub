<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Pending Leave Requests"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LeaveRequest> requests = ViewHelper.<LeaveRequest>list(request, "requests");
%>
<div class="card">
  <h2>Pending Requests</h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Applicant</th><th data-sort>Role</th><th data-sort>Type</th>
      <th data-sort>From</th><th data-sort>To</th><th data-sort>Days</th>
      <th data-sort>Reason</th><th>Contact</th><th style="width:190px">Action</th>
    </tr>
    <% for (LeaveRequest r : requests) { %>
    <tr>
      <td><b><%= r.getUserName() %></b></td>
      <td><small><%= r.getUserRole() %></small></td>
      <td><%= r.getLeaveTypeName() %></td>
      <td><%= r.getStartDate() %></td>
      <td><%= r.getEndDate() %></td>
      <td><%= r.getTotalDays() %></td>
      <td><small><%= r.getReason() != null ? r.getReason() : "—" %></small></td>
      <td><small><%= r.getContactDuringLeave() != null ? r.getContactDuringLeave() : "—" %></small></td>
      <td>
        <form method="post" action="${pageContext.request.contextPath}/leave/review-request" style="display:inline">
          ${csrfField}
          <input type="hidden" name="requestId" value="<%= r.getId() %>">
          <input type="hidden" name="status" value="APPROVED">
          <button type="submit" class="btn btn-primary btn-sm">Approve</button>
        </form>
        <form method="post" action="${pageContext.request.contextPath}/leave/review-request" style="display:inline">
          ${csrfField}
          <input type="hidden" name="requestId" value="<%= r.getId() %>">
          <input type="hidden" name="status" value="REJECTED">
          <button type="submit" class="btn btn-outline btn-sm">Reject</button>
        </form>
      </td>
    </tr>
    <% } %>
    <% if (requests.isEmpty()) { %><tr><td colspan="9" class="empty">No pending leave requests.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
