<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Leave Form"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LeaveType> leaveTypes = ViewHelper.<LeaveType>list(request, "leaveTypes");
%>
<div class="card">
  <h2>New Leave Request</h2>
  <form method="post" action="${pageContext.request.contextPath}/leave/submit-request" class="form-grid">
    ${csrfField}
    <div class="field">
      <label>Leave Type *</label>
      <select name="leaveTypeId" required>
        <option value="">Select Leave Type</option>
        <% for (LeaveType lt : leaveTypes) { %>
        <option value="<%= lt.getId() %>"><%= lt.getName() %> (<%= lt.getMaxDaysPerYear() %> days/year)</option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label>Start Date *</label>
      <input type="date" name="startDate" required>
    </div>
    <div class="field">
      <label>End Date *</label>
      <input type="date" name="endDate" required>
    </div>
    <div class="field">
      <label>Total Days *</label>
      <input type="number" step="0.5" name="totalDays" required min="0.5">
    </div>
    <div class="field full">
      <label>Reason *</label>
      <textarea name="reason" required rows="3" placeholder="Explain the reason for leave..."></textarea>
    </div>
    <div class="field full">
      <label>Contact During Leave</label>
      <input type="text" name="contactDuringLeave" placeholder="Phone/Email where you can be reached">
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Submit Request</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/leave/dashboard">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>