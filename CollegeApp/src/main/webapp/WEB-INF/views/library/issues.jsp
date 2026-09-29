<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Library Issues"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LibraryIssue> issues = ViewHelper.<LibraryIssue>list(request, "issues");
String status = ViewHelper.str(request, "status");
%>
<div class="card">
  <form method="get" class="form-grid" style="margin-bottom:20px">
    <div class="field">
      <label>Status</label>
      <select name="status">
        <option value="">All Status</option>
        <option value="ISSUED" <%= "ISSUED".equals(status) ? "selected" : "" %>>Issued</option>
        <option value="RETURNED" <%= "RETURNED".equals(status) ? "selected" : "" %>>Returned</option>
        <option value="OVERDUE" <%= "OVERDUE".equals(status) ? "selected" : "" %>>Overdue</option>
        <option value="LOST" <%= "LOST".equals(status) ? "selected" : "" %>>Lost</option>
      </select>
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <button type="submit" class="btn btn-primary" style="width:100%">Filter</button>
    </div>
  </form>
</div>
<div class="card">
  <h2>All Issues</h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Book</th><th data-sort>Student</th><th data-sort>Issue Date</th><th data-sort>Due Date</th><th data-sort>Return Date</th><th>Status</th><th>Fine</th><th style="width:150px">Actions</th></tr>
    <% for (LibraryIssue li : issues) { %>
    <tr>
      <td><b><%= li.getBookTitle() %></b> by <%= li.getBookAuthor() %></td>
      <td><%= li.getMemberName() %> (<%= li.getMemberUsername() %>)</td>
      <td><%= li.getIssueDate() %></td>
      <td><%= li.getDueDate() %></td>
      <td><%= li.getReturnDate() != null ? li.getReturnDate() : "-" %></td>
      <td><span class="badge <%= "ISSUED".equals(li.getStatus()) ? "badge-teacher" : ("RETURNED".equals(li.getStatus()) ? "badge-on" : ("OVERDUE".equals(li.getStatus()) ? "badge-off" : "badge-student")) %>"><%= li.getStatus() %></span></td>
      <td><%= li.getFineAmount() > 0 ? String.format("%.2f", li.getFineAmount()) + (li.isFinePaid() ? " (Paid)" : " (Due)") : "-" %></td>
      <td>
        <% if ("ISSUED".equals(li.getStatus()) || "OVERDUE".equals(li.getStatus())) { %>
        <form method="post" action="${pageContext.request.contextPath}/library/return-book" style="display:inline">
          ${csrfField}
          <input type="hidden" name="issueId" value="<%= li.getId() %>">
          <button type="submit" class="btn btn-success btn-sm">Return</button>
        </form>
        <% } %>
      </td>
    </tr>
    <% } %>
    <% if (issues.isEmpty()) { %><tr><td colspan="8" class="empty">No issues found.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>