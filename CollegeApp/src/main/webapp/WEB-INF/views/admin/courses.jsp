<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Manage Courses"); %>
<%@ include file="../layout/top.jsp" %>
<% List<Course> courses = ViewHelper.<Course>list(request, "courses"); %>
<div class="card">
  <h2>All Courses (<%= courses.size() %>)
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/admin/course-form">+ Add Course</a>
  </h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Code</th><th data-sort>Title</th><th data-sort>Credits</th><th data-sort>Semester</th><th data-sort>Teacher</th><th style="width:150px">Actions</th></tr>
    <% for (Course c : courses) { %>
    <tr>
      <td><b><%= c.getCode() %></b></td>
      <td><%= c.getTitle() %></td>
      <td><%= c.getCredits() %></td>
      <td><%= c.getSemester() %></td>
      <td><%= c.getTeacherName() != null ? c.getTeacherName() : "<span class='empty'>Unassigned</span>" %></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/admin/course-form?edit=<%= c.getId() %>">Edit</a>
        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/admin/course-delete"
              onsubmit="return confirm('Delete course and all its enrollments/records?')">
          ${csrfField}
          <input type="hidden" name="id" value="<%= c.getId() %>">
          <button class="btn btn-danger btn-sm">Delete</button>
        </form>
      </td>
    </tr>
    <% } %>
    <% if (courses.isEmpty()) { %><tr><td colspan="6" class="empty">No courses yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
