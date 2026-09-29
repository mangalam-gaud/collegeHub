<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Notifications"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Message> notifications = ViewHelper.<Message>list(request, "notifications");
int unreadNotifCount = ViewHelper.num(request, "unreadNotifCount", 0);
%>
<div class="card">
  <h2>Notifications <span class="badge badge-teacher"><%= unreadNotifCount %> Unread</span></h2>
  <% if (notifications.isEmpty()) { %><div class="empty">No notifications.</div><% } %>
  <% for (Message n : notifications) { %>
  <div class="notice" style="margin-bottom:10px;background:<%= n.isRead() ? "var(--card)" : "color-mix(in srgb, var(--primary-50) 50%, transparent)" %>">
    <h3><%= n.getSubject() %></h3>
    <div class="meta"><%= n.getSentAt() %> <span class="badge badge-teacher"><%= n.getPriority() %></span></div>
    <p><%= n.getBody() %></p>
    <% if (!n.isRead() && n.getSentAt() != null) { %>
    <form method="post" action="${pageContext.request.contextPath}/messages/mark-notification-read" style="display:inline">
      ${csrfField}
      <input type="hidden" name="notificationId" value="<%= n.getId() %>">
      <button type="submit" class="btn btn-outline btn-sm">Mark as Read</button>
    </form>
    <% } %>
  </div>
  <% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>