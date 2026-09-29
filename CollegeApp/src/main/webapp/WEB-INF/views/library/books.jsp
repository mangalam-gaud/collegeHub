<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Library Books"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<LibraryBook> books = ViewHelper.<LibraryBook>list(request, "books");
int totalBooks = ViewHelper.num(request, "totalBooks", 0);
String q = ViewHelper.str(request, "q");
String category = ViewHelper.str(request, "category");
String status = ViewHelper.str(request, "status");
// NB: "page" is the implicit JSP object for this JSP - name the variable pageNo.
int pageNo = ViewHelper.num(request, "page", 1);
if (pageNo < 1) pageNo = 1;
int size = 20;
int totalPages = (int) Math.ceil((double) totalBooks / size);
%>
<div class="card">
  <form method="get" class="form-grid" style="margin-bottom:20px">
    <div class="field">
      <label>Search</label>
      <input type="text" name="q" value="<%= q %>" placeholder="Title, author, ISBN...">
    </div>
    <div class="field">
      <label>Category</label>
      <select name="category">
        <option value="">All Categories</option>
      </select>
    </div>
    <div class="field">
      <label>Status</label>
      <select name="status">
        <option value="">All Status</option>
        <option value="AVAILABLE" <%= "AVAILABLE".equals(status) ? "selected" : "" %>>Available</option>
        <option value="ISSUED" <%= "ISSUED".equals(status) ? "selected" : "" %>>Issued</option>
        <option value="RESERVED" <%= "RESERVED".equals(status) ? "selected" : "" %>>Reserved</option>
        <option value="LOST" <%= "LOST".equals(status) ? "selected" : "" %>>Lost</option>
      </select>
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <button type="submit" class="btn btn-primary" style="width:100%"><span class="lbl-txt">Filter</span></button>
    </div>
  </form>
</div>
<div class="card">
  <h2>Books (<%= totalBooks %>)
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/library/book-form">+ Add Book</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Title</th><th data-sort>Author</th><th data-sort>ISBN</th><th data-sort>Copies</th><th>Status</th><th style="width:150px">Actions</th></tr>
    <% for (LibraryBook b : books) { %>
    <tr>
      <td><b><%= b.getTitle() %></b></td>
      <td><%= b.getAuthor() %></td>
      <td><%= b.getIsbn() != null ? b.getIsbn() : "N/A" %></td>
      <td><%= b.getAvailableCopies() %> / <%= b.getTotalCopies() %></td>
      <td><span class="badge <%= "AVAILABLE".equals(b.getStatus()) ? "badge-on" : ("ISSUED".equals(b.getStatus()) ? "badge-teacher" : "badge-off") %>">
        <%= b.getStatus() %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/library/book-form?edit=<%= b.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (books.isEmpty()) { %><tr><td colspan="6" class="empty">No books found.</td></tr><% } %>
  </table></div>
  <% if (totalPages > 1) { %>
  <div style="display:flex;justify-content:center;gap:8px;margin-top:16px">
    <a class="btn btn-outline btn-sm" href="?q=<%= q %>&category=<%= category %>&status=<%= status %>&page=<%= Math.max(1, pageNo-1) %>" <%= pageNo == 1 ? "disabled" : "" %>>Previous</a>
    <span style="display:flex;align-items:center;padding:0 12px">Page <%= pageNo %> of <%= totalPages %></span>
    <a class="btn btn-outline btn-sm" href="?q=<%= q %>&category=<%= category %>&status=<%= status %>&page=<%= Math.min(totalPages, pageNo+1) %>" <%= pageNo == totalPages ? "disabled" : "" %>>Next</a>
  </div>
  <% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>