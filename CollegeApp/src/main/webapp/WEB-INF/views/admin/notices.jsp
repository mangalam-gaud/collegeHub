<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Notices"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Notice> notices = ViewHelper.<Notice>list(request, "notices"); %>
<div class="grid2">
  <div class="card">
    <h2>Post a Notice</h2>
    <form method="post" action="${pageContext.request.contextPath}/admin/notice-post">
      ${csrfField}
      <div class="field" style="margin-bottom:12px"><label>Title *</label>
        <input name="title" required maxlength="150"></div>
      <div class="field" style="margin-bottom:12px"><label>Message *</label>
        <textarea name="body" required></textarea></div>
      <div class="field" style="margin-bottom:14px"><label>Audience</label>
        <select name="audience">
          <option value="ALL">Everyone</option>
          <option value="STUDENT">Students only</option>
          <option value="TEACHER">Teachers only</option>
        </select></div>
      <button class="btn btn-primary"><span class="lbl-txt">Publish Notice</span></button>
    </form>
  </div>
  <div class="card">
    <h2>Published (<%= notices.size() %>)</h2>
    <% for (Notice n : notices) { %>
      <div class="notice">
        <h3><%= n.getTitle() %></h3>
        <div class="meta"><%= n.getCreatedAt() %> • <%= n.getAuthorName() %> •
          <span class="badge badge-admin"><%= n.getAudience() %></span></div>
        <p><%= n.getBody() %></p>
        <form method="post" style="margin-top:8px" action="${pageContext.request.contextPath}/admin/notice-delete"
              onsubmit="return confirm('Delete this notice?')">
          ${csrfField}
          <input type="hidden" name="id" value="<%= n.getId() %>">
          <button class="btn btn-danger btn-sm">Delete</button>
        </form>
      </div>
    <% } %>
    <% if (notices.isEmpty()) { %><div class="empty">No notices published.</div><% } %>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>
