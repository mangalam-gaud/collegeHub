<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "All Leave Requests"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LeaveRequest> requests = ViewHelper.<LeaveRequest>list(request, "requests");
String status = ViewHelper.str(request, "status");
%>
<div class="card">
  <h2>All Leave Requests</h2>
  <form method="get" style="display:flex;gap:10px;margin-bottom:18px;flex-wrap:wrap;align-items:center">
    <select name="status" style="width:auto" aria-label="Filter by status">
      <option value="">All Statuses</option>
      <option value="PENDING"  <%= "PENDING".equals(status)  ? "selected" : "" %>>Pending</option>
      <option value="APPROVED" <%= "APPROVED".equals(status) ? "selected" : "" %>>Approved</option>
      <option value="REJECTED" <%= "REJECTED".equals(status) ? "selected" : "" %>>Rejected</option>
      <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>Cancelled</option>
    </select>
    <button type="submit" class="btn btn-primary">Filter</button>
    <a class="btn btn-outline" href="${pageContext.request.contextPath}/leave/all-requests">Clear</a>
  </form>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Applicant</th><th data-sort>Role</th><th data-sort>Type</th><th data-sort>From</th>
      <th data-sort>To</th><th data-sort>Days</th><th data-sort>Status</th>
      <th data-sort>Reviewed By</th><th>Remarks</th>
    </tr>
    <% for (LeaveRequest r : requests) { %>
    <tr>
      <td><b><%= r.getUserName() %></b></td>
      <td><small><%= r.getUserRole() %></small></td>
      <td><%= r.getLeaveTypeName() %></td>
      <td><%= r.getStartDate() %></td>
      <td><%= r.getEndDate() %></td>
      <td><%= r.getTotalDays() %></td>
      <td><span class="badge <%= "APPROVED".equalsIgnoreCase(String.valueOf(r.getStatus())) ? "badge-on"
              : ("REJECTED".equalsIgnoreCase(String.valueOf(r.getStatus())) ? "badge-off" : "badge-teacher") %>"><%= r.getStatus() %></span></td>
      <td><small><%= r.getReviewedByName() != null ? r.getReviewedByName() : "—" %></small></td>
      <td><small><%= r.getReviewerRemarks() != null ? r.getReviewerRemarks() : "—" %></small></td>
    </tr>
    <% } %>
    <% if (requests.isEmpty()) { %><tr><td colspan="9" class="empty">No leave requests found.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
