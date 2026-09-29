<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Add Academic Year"); %>
<%@ include file="../layout/top.jsp" %>
<%
AcademicYear ay = (AcademicYear) request.getAttribute("editAcademicYear");
String action = request.getContextPath() + "/academic/academic-year-save";
%>
<div class="card">
  <h2><%= ay == null ? "New Academic Year" : "Edit Academic Year" %></h2>
  <form method="post" action="<%= action %>" class="form-grid">
    ${csrfField}
    <input type="hidden" name="id" value="<%= ay == null ? "" : ay.getId() %>">
    <div class="field">
      <label for="name">Name <span aria-hidden="true">*</span></label>
      <input type="text" id="name" name="name" required
             value="<%= ay == null ? "" : ay.getName() %>" placeholder="e.g. 2026-27">
    </div>
    <div class="field">
      <label for="startDate">Start Date <span aria-hidden="true">*</span></label>
      <input type="date" id="startDate" name="startDate" required
             value="<%= ay == null ? "" : ay.getStartDate() %>">
    </div>
    <div class="field">
      <label for="endDate">End Date <span aria-hidden="true">*</span></label>
      <input type="date" id="endDate" name="endDate" required
             value="<%= ay == null ? "" : ay.getEndDate() %>">
    </div>
    <div class="field">
      <label for="isCurrent">Current Year</label>
      <select id="isCurrent" name="isCurrent">
        <option value="0">No</option>
        <option value="1">Yes</option>
      </select>
    </div>
    <div class="field">
      <label for="isActive">Active</label>
      <select id="isActive" name="isActive">
        <option value="1">Yes</option>
        <option value="0">No</option>
      </select>
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Save Academic Year</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/academic/academic-years">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
