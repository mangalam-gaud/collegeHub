<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "My Leave Requests"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LeaveRequest> requests = ViewHelper.<LeaveRequest>list(request, "requests");
%>
<div class="card">
  <h2>My Leave Requests
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/leave/new-request">+ Apply for Leave</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Type</th><th data-sort>From</th><th data-sort>To</th><th data-sort>Days</th>
      <th data-sort>Reason</th><th data-sort>Applied</th><th data-sort>Status</th><th>Reviewer Remarks</th>
    </tr>
    <% for (LeaveRequest r : requests) { %>
    <tr>
      <td><b><%= r.getLeaveTypeName() %></b></td>
      <td><%= r.getStartDate() %></td>
      <td><%= r.getEndDate() %></td>
      <td><%= r.getTotalDays() %></td>
      <td><small><%= r.getReason() != null ? r.getReason() : "—" %></small></td>
      <td><small><%= r.getAppliedAt() %></small></td>
      <td><span class="badge <%= "APPROVED".equalsIgnoreCase(String.valueOf(r.getStatus())) ? "badge-on"
              : ("REJECTED".equalsIgnoreCase(String.valueOf(r.getStatus())) ? "badge-off" : "badge-teacher") %>"><%= r.getStatus() %></span></td>
      <td><small><%= r.getReviewerRemarks() != null ? r.getReviewerRemarks() : "—" %></small></td>
    </tr>
    <% } %>
    <% if (requests.isEmpty()) { %>
    <tr><td colspan="8" class="empty">You have not applied for any leave yet.</td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
