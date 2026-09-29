<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "My Library Issues"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LibraryIssue> issues = ViewHelper.<LibraryIssue>list(request, "issues");
%>
<div class="card">
  <h2>My Borrowed Books
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/library/books">Browse Catalogue</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Book</th><th data-sort>Author</th><th data-sort>Issued</th>
      <th data-sort>Due</th><th data-sort>Returned</th><th data-sort>Renewals</th>
      <th data-sort>Fine</th><th>Status</th>
    </tr>
    <% for (LibraryIssue i : issues) { %>
    <tr>
      <td><b><%= i.getBookTitle() %></b></td>
      <td><%= i.getBookAuthor() %></td>
      <td><%= i.getIssueDate() %></td>
      <td><%= i.getDueDate() %></td>
      <td><%= i.getReturnDate() != null ? i.getReturnDate() : "—" %></td>
      <td><%= i.getRenewedCount() %> / <%= i.getMaxRenewals() %></td>
      <td><%= i.getFineAmount() > 0 ? String.format("%,.2f", i.getFineAmount()) : "—" %></td>
      <td><span class="badge <%= "RETURNED".equalsIgnoreCase(String.valueOf(i.getStatus())) ? "badge-on"
              : ("OVERDUE".equalsIgnoreCase(String.valueOf(i.getStatus())) ? "badge-off" : "badge-teacher") %>"><%= i.getStatus() %></span></td>
    </tr>
    <% } %>
    <% if (issues.isEmpty()) { %>
    <tr><td colspan="8" class="empty">You have no borrowed books. Visit the catalogue to borrow one.</td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
