<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Book Form"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2><%= request.getAttribute("editBook") != null ? "Edit Book" : "Add Book" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/library/book-save" class="form-grid">
    ${csrfField}
    <% if (request.getAttribute("editBook") != null) { %>
      <input type="hidden" name="id" value="<%= ((LibraryBook)request.getAttribute("editBook")).getId() %>">
    <% } %>
    <div class="field">
      <label>ISBN</label>
      <input type="text" name="isbn" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getIsbn() : "" %>" placeholder="ISBN-13">
    </div>
    <div class="field">
      <label>Title *</label>
      <input type="text" name="title" required value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getTitle() : "" %>" placeholder="Book Title">
    </div>
    <div class="field">
      <label>Author *</label>
      <input type="text" name="author" required value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getAuthor() : "" %>" placeholder="Author Name">
    </div>
    <div class="field">
      <label>Publisher</label>
      <input type="text" name="publisher" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getPublisher() : "" %>">
    </div>
    <div class="field">
      <label>Edition</label>
      <input type="text" name="edition" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getEdition() : "" %>">
    </div>
    <div class="field">
      <label>Publication Year</label>
      <input type="number" name="publicationYear" min="1900" max="<%= java.time.Year.now().getValue() %>" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getPublicationYear() : "" %>">
    </div>
    <div class="field">
      <label>Category ID</label>
      <input type="number" name="categoryId" min="1" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getCategoryId() : "" %>">
    </div>
    <div class="field">
      <label>Total Copies</label>
      <input type="number" name="totalCopies" min="1" required value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getTotalCopies() : "1" %>">
    </div>
    <div class="field">
      <label>Available Copies</label>
      <input type="number" name="availableCopies" min="0" required value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getAvailableCopies() : "1" %>">
    </div>
    <div class="field">
      <label>Location Rack</label>
      <input type="text" name="locationRack" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getLocationRack() : "" %>">
    </div>
    <div class="field">
      <label>Location Shelf</label>
      <input type="text" name="locationShelf" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getLocationShelf() : "" %>">
    </div>
    <div class="field">
      <label>Price</label>
      <input type="number" step="0.01" name="price" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getPrice() : "" %>">
    </div>
    <div class="field">
      <label>Language</label>
      <input type="text" name="language" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getLanguage() : "English" %>">
    </div>
    <div class="field">
      <label>Pages</label>
      <input type="number" name="pages" min="1" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getPages() : "" %>">
    </div>
    <div class="field">
      <label>Description</label>
      <textarea name="description" rows="3"><%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getDescription() : "" %></textarea>
    </div>
    <div class="field">
      <label>Cover Image URL</label>
      <input type="text" name="coverImage" value="<%= request.getAttribute("editBook") != null ? ((LibraryBook)request.getAttribute("editBook")).getCoverImage() : "" %>">
    </div>
    <div class="field">
      <label>Status</label>
      <select name="status">
        <option value="AVAILABLE" <%= request.getAttribute("editBook") != null && "AVAILABLE".equals(((LibraryBook)request.getAttribute("editBook")).getStatus()) ? "selected" : "" %>>Available</option>
        <option value="ISSUED" <%= request.getAttribute("editBook") != null && "ISSUED".equals(((LibraryBook)request.getAttribute("editBook")).getStatus()) ? "selected" : "" %>>Issued</option>
        <option value="RESERVED" <%= request.getAttribute("editBook") != null && "RESERVED".equals(((LibraryBook)request.getAttribute("editBook")).getStatus()) ? "selected" : "" %>>Reserved</option>
        <option value="LOST" <%= request.getAttribute("editBook") != null && "LOST".equals(((LibraryBook)request.getAttribute("editBook")).getStatus()) ? "selected" : "" %>>Lost</option>
        <option value="DAMAGED" <%= request.getAttribute("editBook") != null && "DAMAGED".equals(((LibraryBook)request.getAttribute("editBook")).getStatus()) ? "selected" : "" %>>Damaged</option>
        <option value="WITHDRAWN" <%= request.getAttribute("editBook") != null && "WITHDRAWN".equals(((LibraryBook)request.getAttribute("editBook")).getStatus()) ? "selected" : "" %>>Withdrawn</option>
      </select>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/library/books">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>