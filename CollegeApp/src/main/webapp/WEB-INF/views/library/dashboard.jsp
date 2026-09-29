<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Library Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<div class="stats">
  <div class="stat"><div class="num"><%= request.getAttribute("totalBooks") %></div><div class="lbl">Total Books</div></div>
  <div class="stat"><div class="num"><%= request.getAttribute("availableBooks") %></div><div class="lbl">Available</div></div>
  <div class="stat"><div class="num"><%= request.getAttribute("issuedBooks") %></div><div class="lbl">Issued</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Quick Actions</h2>
    <div style="display:flex;gap:10px;flex-wrap:wrap">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/library/book-form">+ Add Book</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/library/issues">View Issues</a>
    </div>
  </div>
  <div class="card">
    <h2>Recent Issues</h2>
    <div class="table-wrap"><table>
      <tr><th>Book</th><th>Student</th><th>Issue Date</th><th>Due Date</th><th>Status</th></tr>
      <tr><td colspan="5" class="empty">No recent issues.</td></tr>
    </table></div>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>