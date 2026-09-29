<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Department Form"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2><%= request.getAttribute("editDepartment") != null ? "Edit Department" : "Add Department" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/admin/department-save" class="form-grid">
    ${csrfField}
    <% if (request.getAttribute("editDepartment") != null) { %>
      <input type="hidden" name="id" value="<%= ((Department)request.getAttribute("editDepartment")).getId() %>">
    <% } %>
    <div class="field">
      <label>Name *</label>
      <input type="text" name="name" required value="<%= request.getAttribute("editDepartment") != null ? ((Department)request.getAttribute("editDepartment")).getName() : "" %>">
    </div>
    <div class="field">
      <label>Code *</label>
      <input type="text" name="code" required value="<%= request.getAttribute("editDepartment") != null ? ((Department)request.getAttribute("editDepartment")).getCode() : "" %>" placeholder="e.g., CSE">
    </div>
    <div class="field">
      <label>HOD</label>
      <select name="hodId">
        <option value="0">Select HOD</option>
        <% List<User> teachers = ViewHelper.<User>list(request, "teachers");
           if (teachers != null) {
             for (User t : teachers) { %>
        <option value="<%= t.getId() %>" <%= request.getAttribute("editDepartment") != null && ((Department)request.getAttribute("editDepartment")).getHodId() == t.getId() ? "selected" : "" %>><%= t.getFullName() %></option>
        <% } } %>
      </select>
    </div>
    <div class="field full">
      <label>Description</label>
      <textarea name="description" rows="3"><%= request.getAttribute("editDepartment") != null ? ((Department)request.getAttribute("editDepartment")).getDescription() : "" %></textarea>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/departments">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>