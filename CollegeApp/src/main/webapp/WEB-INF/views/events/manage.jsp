<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Manage Events"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Event> events = ViewHelper.<Event>list(request, "events");
%>
<div class="card">
  <h2>Manage Events
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/events/event-form">+ Create Event</a>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/events/list">View Public List</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Title</th><th data-sort>Type</th><th data-sort>Starts</th><th data-sort>Ends</th>
      <th data-sort>Location</th><th data-sort>Organizer</th><th data-sort>Audience</th>
      <th data-sort>Registrations</th><th>Published</th><th style="width:150px">Actions</th>
    </tr>
    <% for (Event e : events) { %>
    <tr>
      <td><b><%= e.getTitle() %></b></td>
      <td><%= e.getEventType() %></td>
      <td><small><%= e.getStartDatetime() %></small></td>
      <td><small><%= e.getEndDatetime() %></small></td>
      <td><small><%= e.getLocation() != null ? e.getLocation() : "—" %></small></td>
      <td><small><%= e.getOrganizerName() != null ? e.getOrganizerName() : "—" %></small></td>
      <td><small><%= e.getTargetAudience() %></small></td>
      <td><%= e.getRegisteredCount() %><% if (e.getMaxParticipants() > 0) { %> / <%= e.getMaxParticipants() %><% } %></td>
      <td><span class="badge <%= e.isPublished() ? "badge-on" : "badge-off" %>"><%= e.isPublished() ? "Yes" : "No" %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/events/detail?id=<%= e.getId() %>">View</a>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/events/event-form?edit=<%= e.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (events.isEmpty()) { %><tr><td colspan="10" class="empty">No events created yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
