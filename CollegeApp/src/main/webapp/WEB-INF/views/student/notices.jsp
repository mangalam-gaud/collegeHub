<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Notices"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Notice> notices = ViewHelper.<Notice>list(request, "notices"); %>
<div class="card">
  <h2>College Notices (<%= notices.size() %>)</h2>
  <% for (Notice n : notices) { %>
    <div class="notice">
      <h3><%= n.getTitle() %></h3>
      <div class="meta"><%= n.getCreatedAt() %> • <%= n.getAuthorName() %></div>
      <p><%= n.getBody() %></p>
    </div>
  <% } %>
  <% if (notices.isEmpty()) { %><div class="empty">No notices right now.</div><% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>
