<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Grievance Details"); %>
<%@ include file="../layout/top.jsp" %>
<%
Grievance grievance = (Grievance) request.getAttribute("grievance");
User user = (User) session.getAttribute("user");
boolean isAdmin = "ADMIN".equals(user.getRole());
%>
<div class="card">
  <h2><%= grievance.getSubject() %>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/grievance/dashboard">Back</a></h2>
  <div class="notice" style="margin-bottom:20px">
    <h3><%= grievance.getSubject() %></h3>
    <div class="meta">
      <span class="badge badge-teacher"><%= grievance.getCategory() %></span>
      <span class="badge <%= "URGENT".equals(grievance.getPriority()) ? "badge-off" : ("HIGH".equals(grievance.getPriority()) ? "badge-teacher" : "badge-student") %>"><%= grievance.getPriority() %></span>
      <span class="badge <%= "RESOLVED".equals(grievance.getStatus()) || "CLOSED".equals(grievance.getStatus()) ? "badge-on" : ("IN_PROGRESS".equals(grievance.getStatus()) ? "badge-teacher" : "badge-off") %>"><%= grievance.getStatus() %></span>
    </div>
    <p><%= grievance.getDescription() %></p>
    <div style="margin-top:16px;font-size:12px;color:var(--gray-600)">
      Submitted: <%= grievance.getCreatedAt() %> <%= grievance.isAnonymous() ? "· Anonymous" : "" %>
      <% if (grievance.getResolvedAt() != null) { %> · Resolved: <%= grievance.getResolvedAt() %><% } %>
    </div>
  </div>
  
  <% if (isAdmin) { %>
  <div class="card" style="margin-top:20px">
    <h3>Admin Actions</h3>
    <form method="post" action="${pageContext.request.contextPath}/grievance/update" class="form-grid">
      ${csrfField}
      <input type="hidden" name="id" value="<%= grievance.getId() %>">
      <div class="field">
        <label>Status</label>
        <select name="status">
          <option value="SUBMITTED" <%= "SUBMITTED".equals(grievance.getStatus()) ? "selected" : "" %>>Submitted</option>
          <option value="ACKNOWLEDGED" <%= "ACKNOWLEDGED".equals(grievance.getStatus()) ? "selected" : "" %>>Acknowledged</option>
          <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(grievance.getStatus()) ? "selected" : "" %>>In Progress</option>
          <option value="RESOLVED" <%= "RESOLVED".equals(grievance.getStatus()) ? "selected" : "" %>>Resolved</option>
          <option value="CLOSED" <%= "CLOSED".equals(grievance.getStatus()) ? "selected" : "" %>>Closed</option>
          <option value="REOPENED" <%= "REOPENED".equals(grievance.getStatus()) ? "selected" : "" %>>Reopened</option>
        </select>
      </div>
      <div class="field">
        <label>Assigned To</label>
        <input type="number" name="assignedTo" value="<%= grievance.getAssignedTo() %>" placeholder="User ID">
      </div>
      <div class="field full">
        <label>Resolution</label>
        <textarea name="resolution" rows="3"><%= grievance.getResolution() != null ? grievance.getResolution() : "" %></textarea>
      </div>
      <div class="field">
        <label>Resolved At</label>
        <input type="datetime-local" name="resolvedAt" value="<%= grievance.getResolvedAt() != null ? grievance.getResolvedAt().replace(" ", "T") : "" %>">
      </div>
      <div class="field">
        <label>Satisfaction Rating (1-5)</label>
        <input type="number" name="satisfactionRating" min="1" max="5" value="<%= grievance.getSatisfactionRating() %>">
      </div>
      <div class="field full">
        <label>Feedback</label>
        <textarea name="feedbackText" rows="2"><%= grievance.getFeedbackText() != null ? grievance.getFeedbackText() : "" %></textarea>
      </div>
      <div class="form-actions full">
        <button type="submit" class="btn btn-primary">Update</button>
      </div>
    </form>
  </div>
  <% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>