<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Events"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Event> events = ViewHelper.<Event>list(request, "events");
List<Event> upcoming = ViewHelper.<Event>list(request, "upcoming");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= events.size() %></div><div class="lbl">Published Events</div></div>
  <div class="stat"><div class="num"><%= upcoming.size() %></div><div class="lbl">Upcoming For You</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Upcoming for You</h2>
    <% if (upcoming.isEmpty()) { %>
      <div class="empty">Nothing scheduled for you right now.</div>
    <% } %>
    <% for (Event e : upcoming) { %>
    <div class="notice" style="margin-bottom:10px">
      <h3><%= e.getTitle() %></h3>
      <div class="meta"><%= e.getStartDatetime() %> · <span class="badge badge-teacher"><%= e.getEventType() %></span></div>
      <% if (e.getLocation() != null) { %><p>📍 <%= e.getLocation() %></p><% } %>
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/events/detail?id=<%= e.getId() %>">Details</a>
    </div>
    <% } %>
  </div>
  <div class="card">
    <h2>All Events
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/events/manage">Manage</a></h2>
    <% if (events.isEmpty()) { %>
      <div class="empty">No events published yet.</div>
    <% } %>
    <% for (Event e : events) { %>
    <div class="notice" style="margin-bottom:10px">
      <h3><%= e.getTitle() %></h3>
      <div class="meta"><%= e.getStartDatetime() %> · <span class="badge badge-teacher"><%= e.getEventType() %></span></div>
      <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/events/detail?id=<%= e.getId() %>">View</a>
    </div>
    <% } %>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>
