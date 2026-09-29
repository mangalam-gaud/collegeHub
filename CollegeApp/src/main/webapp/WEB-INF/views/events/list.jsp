<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Events"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Event> events = ViewHelper.<Event>list(request, "events");
List<Event> upcoming = ViewHelper.<Event>list(request, "upcoming");
String type = ViewHelper.str(request, "type");
%>
<div class="card">
  <form method="get" style="display:flex;gap:10px;margin-bottom:20px;flex-wrap:wrap">
    <select name="type" style="width:auto">
      <option value="">All Types</option>
      <option value="ACADEMIC" <%= "ACADEMIC".equals(type) ? "selected" : "" %>>Academic</option>
      <option value="CULTURAL" <%= "CULTURAL".equals(type) ? "selected" : "" %>>Cultural</option>
      <option value="SPORTS" <%= "SPORTS".equals(type) ? "selected" : "" %>>Sports</option>
      <option value="SEMINAR" <%= "SEMINAR".equals(type) ? "selected" : "" %>>Seminar</option>
      <option value="WORKSHOP" <%= "WORKSHOP".equals(type) ? "selected" : "" %>>Workshop</option>
      <option value="HOLIDAY" <%= "HOLIDAY".equals(type) ? "selected" : "" %>>Holiday</option>
      <option value="EXAM" <%= "EXAM".equals(type) ? "selected" : "" %>>Exam</option>
      <option value="MEETING" <%= "MEETING".equals(type) ? "selected" : "" %>>Meeting</option>
    </select>
    <button type="submit" class="btn btn-primary">Filter</button>
    <a class="btn btn-outline" href="${pageContext.request.contextPath}/events/list">Clear</a>
  </form>
</div>
<div class="grid2">
  <div class="card">
    <h2>Upcoming for You</h2>
    <%
      if (upcoming == null || upcoming.isEmpty()) {
    %><div class="empty">No upcoming events.</div><%
      } else {
        for (Event e : upcoming) {
    %><div class="notice" style="margin-bottom:10px">
      <h3><%= e.getTitle() %></h3>
      <div class="meta"><%= e.getStartDatetime() %> · <span class="badge badge-teacher"><%= e.getEventType() %></span></div>
      <p><%= e.getDescription() != null ? e.getDescription().substring(0, Math.min(100, e.getDescription().length())) + (e.getDescription().length() > 100 ? "..." : "") : "" %></p>
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/events/detail?id=<%= e.getId() %>">Details</a>
    </div>
    <%
        }
      }
    %>
  </div>
  <div class="card">
    <h2>All Events
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/events/manage">Manage</a></h2>
    <% if (events.isEmpty()) { %><div class="empty">No events found.</div><%
      } else {
        for (Event e : events) {
    %><div class="notice" style="margin-bottom:10px">
      <h3><%= e.getTitle() %></h3>
      <div class="meta"><%= e.getStartDatetime() %> · <span class="badge badge-teacher"><%= e.getEventType() %></span></div>
      <p><%= e.getLocation() != null ? "📍 " + e.getLocation() : "" %></p>
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/events/detail?id=<%= e.getId() %>">View</a>
      <% if (e.isRegistrationRequired()) { %>
      <form method="post" action="${pageContext.request.contextPath}/events/register" style="display:inline;margin-left:10px">
        ${csrfField}
        <input type="hidden" name="eventId" value="<%= e.getId() %>">
        <button type="submit" class="btn btn-outline btn-sm">Register</button>
      </form>
      <% } %>
    </div>
    <% 
        }
      }
    %>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>