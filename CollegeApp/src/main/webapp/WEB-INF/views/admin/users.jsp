<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Manage Users"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<User> students = ViewHelper.<User>list(request, "students");
List<User> teachers = ViewHelper.<User>list(request, "teachers");
%>
<% if (request.getAttribute("error") != null) { %>
  <div class="alert alert-error"><%= request.getAttribute("error") %></div>
<% } %>

<div class="card">
  <form method="get" id="userFilter" style="display:flex;gap:10px;max-width:520px;flex-wrap:wrap">
    <input type="search" name="q" data-filter="table" placeholder="Filter by name, username or email… ( / )"
           value="<%= request.getAttribute("q") %>" style="flex:1;min-width:220px" aria-label="Filter users">
    <button class="btn btn-primary">Search</button>
    <% if (request.getAttribute("q") != null && !(ViewHelper.str(request, "q")).isEmpty()) { %>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/users">Clear</a>
    <% } %>
    <span class="badge badge-admin" style="align-self:center">
      <span data-filter-count="table">0</span> shown</span>
  </form>
</div>

<div class="card">
  <h2>Students (<span data-count="table.students tbody tr">0</span>)
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/admin/user-form?role=STUDENT">+ Add Student</a></h2>
  <div class="table-wrap"><table class="students">
    <tr><th data-sort>Name</th><th data-sort>Username</th><th data-sort>Email</th><th data-sort>Status</th><th style="width:230px">Actions</th></tr>
    <% for (User u : students) { %>
    <tr>
      <td><b><%= u.getFullName() %></b></td>
      <td><%= u.getUsername() %></td>
      <td><%= u.getEmail() %></td>
      <td><span class="badge <%= u.isActive() ? "badge-on" : "badge-off" %>"><%= u.isActive() ? "Active" : "Disabled" %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="?edit=<%= u.getId() %>&role=STUDENT">Edit</a>
        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/admin/user-toggle">
          ${csrfField}
          <input type="hidden" name="id" value="<%= u.getId() %>"><input type="hidden" name="to" value="<%= u.isActive() ? 0 : 1 %>">
          <button class="btn btn-outline btn-sm"><%= u.isActive() ? "Disable" : "Enable" %></button>
        </form>
        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/admin/user-delete"
              onsubmit="return confirm('Delete this user permanently?')">
          ${csrfField}
          <input type="hidden" name="id" value="<%= u.getId() %>">
          <button class="btn btn-danger btn-sm">Delete</button>
        </form>
      </td>
    </tr>
    <% } %>
    <% if (students.isEmpty()) { %><tr><td colspan="5" class="empty">No students yet.</td></tr><% } %>
  </table></div>
</div>

<div class="card">
  <h2>Teachers (<span data-count="table.teachers tbody tr">0</span>)
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/admin/user-form?role=TEACHER">+ Add Teacher</a></h2>
  <div class="table-wrap"><table class="teachers">
    <tr><th data-sort>Name</th><th data-sort>Username</th><th data-sort>Email</th><th data-sort>Status</th><th style="width:230px">Actions</th></tr>
    <% for (User u : teachers) { %>
    <tr>
      <td><b><%= u.getFullName() %></b></td>
      <td><%= u.getUsername() %></td>
      <td><%= u.getEmail() %></td>
      <td><span class="badge <%= u.isActive() ? "badge-on" : "badge-off" %>"><%= u.isActive() ? "Active" : "Disabled" %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="?edit=<%= u.getId() %>&role=TEACHER">Edit</a>
        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/admin/user-toggle">
          ${csrfField}
          <input type="hidden" name="id" value="<%= u.getId() %>"><input type="hidden" name="to" value="<%= u.isActive() ? 0 : 1 %>">
          <button class="btn btn-outline btn-sm"><%= u.isActive() ? "Disable" : "Enable" %></button>
        </form>
        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/admin/user-delete"
              onsubmit="return confirm('Delete this user permanently?')">
          ${csrfField}
          <input type="hidden" name="id" value="<%= u.getId() %>">
          <button class="btn btn-danger btn-sm">Delete</button>
        </form>
      </td>
    </tr>
    <% } %>
    <% if (teachers.isEmpty()) { %><tr><td colspan="5" class="empty">No teachers yet.</td></tr><% } %>
  </table></div>
</div>

<%@ include file="../layout/bottom.jsp" %>
