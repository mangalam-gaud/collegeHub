<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Program Form"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Department> departments = ViewHelper.<Department>list(request, "departments");
%>
<div class="card">
  <h2><%= request.getAttribute("editProgram") != null ? "Edit Program" : "Add Program" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/admin/program-save" class="form-grid">
    ${csrfField}
    <% if (request.getAttribute("editProgram") != null) { %>
      <input type="hidden" name="id" value="<%= ((Program)request.getAttribute("editProgram")).getId() %>">
    <% } %>
    <div class="field">
      <label>Code *</label>
      <input type="text" name="code" required value="<%= request.getAttribute("editProgram") != null ? ((Program)request.getAttribute("editProgram")).getCode() : "" %>" placeholder="e.g., BTECH-CSE">
    </div>
    <div class="field">
      <label>Name *</label>
      <input type="text" name="name" required value="<%= request.getAttribute("editProgram") != null ? ((Program)request.getAttribute("editProgram")).getName() : "" %>">
    </div>
    <div class="field">
      <label>Department *</label>
      <select name="departmentId" required>
        <option value="">Select Department</option>
        <% for (Department d : departments) { %>
        <option value="<%= d.getId() %>" <%= request.getAttribute("editProgram") != null && ((Program)request.getAttribute("editProgram")).getDepartmentId() == d.getId() ? "selected" : "" %>><%= d.getName() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label>Duration (Years) *</label>
      <input type="number" name="durationYears" min="1" max="6" required value="<%= request.getAttribute("editProgram") != null ? ((Program)request.getAttribute("editProgram")).getDurationYears() : "4" %>">
    </div>
    <div class="field">
      <label>Total Semesters *</label>
      <input type="number" name="totalSemesters" min="1" max="12" required value="<%= request.getAttribute("editProgram") != null ? ((Program)request.getAttribute("editProgram")).getTotalSemesters() : "8" %>">
    </div>
    <div class="field full">
      <label>Eligibility Criteria</label>
      <textarea name="eligibilityCriteria" rows="3"><%= request.getAttribute("editProgram") != null ? ((Program)request.getAttribute("editProgram")).getEligibilityCriteria() : "" %></textarea>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/programs">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>