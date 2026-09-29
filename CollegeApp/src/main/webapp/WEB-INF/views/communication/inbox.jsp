<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Inbox"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Message> messages = ViewHelper.<Message>list(request, "messages");
int unreadCount = ViewHelper.num(request, "unreadCount", 0);
%>
<div class="card">
  <h2>Inbox <span class="badge badge-teacher"><%= unreadCount %> Unread</span>
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/messages/compose">+ Compose</a></h2>
  <% if (messages.isEmpty()) { %><div class="empty">No messages.</div><% } %>
  <div class="table-wrap"><table>
    <tr><th>From</th><th>Subject</th><th>Date</th><th>Status</th></tr>
    <% for (Message m : messages) { %>
    <tr class="<%= m.isRead() ? "" : "hit" %>">
      <td><b><%= m.getSenderName() %></b> <span class="badge badge-teacher"><%= m.getSenderRole() %></span></td>
      <td><%= m.getSubject() != null ? m.getSubject() : "(No Subject)" %></td>
      <td><%= m.getSentAt() %></td>
      <td><%= m.isRead() ? "Read" : "Unread" %></td>
    </tr>
    <% } %>
    <% if (messages.isEmpty()) { %><tr><td colspan="4" class="empty">Inbox is empty.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>