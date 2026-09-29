<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Sent Messages"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Message> messages = ViewHelper.<Message>list(request, "messages");
%>
<div class="card">
  <h2>Sent Messages
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/messages/compose">+ Compose</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>To</th><th data-sort>Subject</th><th data-sort>Type</th><th data-sort>Priority</th><th data-sort>Sent</th><th>Preview</th></tr>
    <% for (Message m : messages) { %>
    <tr>
      <td><b><%= m.getRecipientName() != null ? m.getRecipientName() : "—" %></b></td>
      <td><%= m.getSubject() %></td>
      <td><%= m.getMessageType() %></td>
      <td><span class="badge <%= "HIGH".equalsIgnoreCase(String.valueOf(m.getPriority())) ? "badge-off"
              : ("LOW".equalsIgnoreCase(String.valueOf(m.getPriority())) ? "badge-teacher" : "badge-on") %>"><%= m.getPriority() %></span></td>
      <td><small><%= m.getSentAt() %></small></td>
      <td><small><%= m.getBody() != null && m.getBody().length() > 70 ? m.getBody().substring(0,70) + "…" : m.getBody() %></small></td>
    </tr>
    <% } %>
    <% if (messages.isEmpty()) { %><tr><td colspan="6" class="empty">You have not sent any messages.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
