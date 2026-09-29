<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Issue Book"); %>
<%@ include file="../layout/top.jsp" %>
<%
LibraryBook book = (LibraryBook) request.getAttribute("book");
List<User> members = ViewHelper.<User>list(request, "members");
%>
<div class="card">
  <h2>Issue Book</h2>
  <% if (book == null) { %>
    <div class="empty">Select a book from the <a href="${pageContext.request.contextPath}/library/books">catalogue</a> to issue it.</div>
  <% } else { %>
  <div class="notice" style="margin-bottom:18px">
    <h3><%= book.getTitle() %></h3>
    <p><%= book.getAuthor() %> · <%= book.getIsbn() != null ? book.getIsbn() : "N/A" %> ·
       Copies available: <b><%= book.getAvailableCopies() %></b> / <%= book.getTotalCopies() %></p>
  </div>
  <% } %>
  <form method="post" action="${pageContext.request.contextPath}/library/issue-book" class="form-grid">
    ${csrfField}
    <div class="field">
      <label for="bookId">Book <span aria-hidden="true">*</span></label>
      <input type="number" id="bookId" name="bookId" required min="1"
             value="<%= book == null ? "" : String.valueOf(book.getId()) %>">
    </div>
    <div class="field">
      <label for="memberId">Member <span aria-hidden="true">*</span></label>
      <select id="memberId" name="memberId" required>
        <option value="">Select student</option>
        <% for (User u : members) { %>
        <option value="<%= u.getId() %>"><%= u.getFullName() %> (<%= u.getUsername() %>)</option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="issueDate">Issue Date <span aria-hidden="true">*</span></label>
      <input type="date" id="issueDate" name="issueDate" required value="<%= java.time.LocalDate.now() %>">
    </div>
    <div class="field">
      <label for="dueDate">Due Date <span aria-hidden="true">*</span></label>
      <input type="date" id="dueDate" name="dueDate" required value="<%= java.time.LocalDate.now().plusDays(14) %>">
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Issue Book</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/library/issues">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
