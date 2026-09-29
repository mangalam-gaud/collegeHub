<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Notices"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Notice> notices = ViewHelper.<Notice>list(request, "notices"); %>
<div class="grid2">
  <div class="card">
    <h2>Post Notice to Students</h2>
    <form method="post" action="${pageContext.request.contextPath}/teacher/notice-post">
      ${csrfField}
      <div class="field" style="margin-bottom:12px"><label>Title *</label>
        <input name="title" required maxlength="150"></div>
      <div class="field" style="margin-bottom:12px"><label>Message *</label>
        <textarea name="body" required></textarea></div>
      <div class="field" style="margin-bottom:14px"><label>Audience</label>
        <select name="audience">
          <option value="STUDENT">Students only</option>
          <option value="ALL">Everyone</option>
        </select></div>
      <button class="btn btn-primary">Publish</button>
    </form>
  </div>
  <div class="card">
    <h2>All Notices</h2>
    <% for (Notice n : notices) { %>
      <div class="notice">
        <h3><%= n.getTitle() %></h3>
        <div class="meta"><%= n.getCreatedAt() %> • <%= n.getAuthorName() %></div>
        <p><%= n.getBody() %></p>
      </div>
    <% } %>
    <% if (notices.isEmpty()) { %><div class="empty">No notices.</div><% } %>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>
