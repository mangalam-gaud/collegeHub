<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Event Details"); %>
<%@ include file="../layout/top.jsp" %>
<%
Event event = (Event) request.getAttribute("event");
// `me` (the signed-in User) is already in scope from layout/top.jsp.
%>
<% if (event == null) { %>
  <div class="card">
    <h2>Event not found</h2>
    <div class="empty">
      This event does not exist or may have been removed.
      <br><br>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/events/list">Back to Events</a>
    </div>
  </div>
<% } else { %>
<div class="card">
  <h2><%= event.getTitle() %>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/events/list">Back</a></h2>
  <div class="notice" style="margin-bottom:20px">
    <h3><%= event.getTitle() %></h3>
    <div class="meta">
      <%= event.getStartDatetime() %> - <%= event.getEndDatetime() != null ? event.getEndDatetime() : "TBD" %>
      <span class="badge badge-teacher"><%= event.getEventType() %></span>
    </div>
    <p><strong>Location:</strong> <%= event.getLocation() != null ? event.getLocation() : "TBD" %></p>
    <% if (event.getDescription() != null) { %><p><%= event.getDescription() %></p><% } %>
    <div style="margin-top:16px">
      <span class="badge <%= event.isPublished() ? "badge-on" : "badge-off" %>"><%= event.isPublished() ? "Published" : "Draft" %></span>
      <span class="badge badge-teacher"><%= event.getTargetAudience() %></span>
      <% if (event.getMaxParticipants() > 0) { %>
      <span class="badge badge-teacher">Max: <%= event.getMaxParticipants() %></span>
      <% } %>
      <% if (event.getRegistrationDeadline() != null) { %>
      <span class="badge badge-on">Register by: <%= event.getRegistrationDeadline() %></span>
      <% } %>
    </div>
  </div>

  <% if (event.isRegistrationRequired() && me != null && "STUDENT".equals(me.getRole())) { %>
  <form method="post" action="${pageContext.request.contextPath}/events/register" style="display:inline">
    ${csrfField}
    <input type="hidden" name="eventId" value="<%= event.getId() %>">
    <button type="submit" class="btn btn-primary">Register</button>
  </form>
  <% } %>
</div>
<% } %>
<%@ include file="../layout/bottom.jsp" %>
