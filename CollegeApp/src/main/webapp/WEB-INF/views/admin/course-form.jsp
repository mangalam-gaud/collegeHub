<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<%
Course editCourse = (Course) request.getAttribute("editCourse");
List<User> teachers = ViewHelper.<User>list(request, "teachers");
request.setAttribute("pageTitle", editCourse != null ? "Edit Course" : "Add Course");
%>
<%@ include file="../layout/top.jsp" %>
<div class="card" style="max-width:640px">
  <h2><%= editCourse != null ? "Edit Course" : "New Course" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/admin/course-save">
    ${csrfField}
    <% if (editCourse != null) { %><input type="hidden" name="id" value="<%= editCourse.getId() %>"><% } %>
    <div class="form-grid">
      <div class="field"><label>Course Code *</label>
        <input name="code" required placeholder="CS101"
               value="<%= editCourse != null ? editCourse.getCode() : "" %>"></div>
      <div class="field"><label>Title *</label>
        <input name="title" required placeholder="Data Structures"
               value="<%= editCourse != null ? editCourse.getTitle() : "" %>"></div>
      <div class="field"><label>Credits</label>
        <input type="number" name="credits" min="1" max="10" value="<%= editCourse != null ? editCourse.getCredits() : 3 %>"></div>
      <div class="field"><label>Semester</label>
        <input type="number" name="semester" min="1" max="8" value="<%= editCourse != null ? editCourse.getSemester() : 1 %>"></div>
      <div class="field full"><label>Assign Teacher</label>
        <select name="teacherId">
          <option value="">— Unassigned —</option>
          <% for (User t : teachers) { %>
            <option value="<%= t.getId() %>" <%= editCourse != null && editCourse.getTeacherId() != null && editCourse.getTeacherId() == t.getId() ? "selected" : "" %>><%= t.getFullName() %></option>
          <% } %>
        </select></div>
    </div>
    <div class="form-actions">
      <button class="btn btn-primary"><span class="lbl-txt">Save Course</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/courses">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
