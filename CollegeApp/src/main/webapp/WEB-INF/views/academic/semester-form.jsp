<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Semester Form"); %>
<%@ include file="../layout/top.jsp" %>
<% if (request.getAttribute("error") != null) { %>
  <div class="alert alert-error"><%= request.getAttribute("error") %></div>
<% } %>
<div class="card">
  <h2><%= request.getAttribute("editSemester") != null ? "Edit Semester" : "Add Semester" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/academic/semester-save" class="form-grid">
    ${csrfField}
    <input type="hidden" name="academicYearId" value="<%= request.getParameter("academicYearId") != null ? request.getParameter("academicYearId") : (request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getAcademicYearId() : "") %>">
    <% if (request.getAttribute("editSemester") != null) { %>
      <input type="hidden" name="id" value="<%= ((Semester)request.getAttribute("editSemester")).getId() %>">
    <% } %>
    <div class="field">
      <label>Academic Year</label>
      <select name="academicYearId" required>
        <option value="">Select Academic Year</option>
        <% List<AcademicYear> years = ViewHelper.<AcademicYear>list(request, "academicYears"); 
           if (years != null) {
             for (AcademicYear ay : years) { %>
        <option value="<%= ay.getId() %>" <%= request.getAttribute("editSemester") != null && ((Semester)request.getAttribute("editSemester")).getAcademicYearId() == ay.getId() ? "selected" : "" %>><%= ay.getName() %></option>
        <% } } %>
      </select>
    </div>
    <div class="field">
      <label>Name</label>
      <input type="text" name="name" required value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getName() : "" %>" placeholder="e.g., Fall 2024">
    </div>
    <div class="field">
      <label>Number</label>
      <input type="number" name="number" required min="1" max="8" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getNumber() : "" %>">
    </div>
    <div class="field">
      <label>Start Date</label>
      <input type="date" name="startDate" required value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getStartDate() : "" %>">
    </div>
    <div class="field">
      <label>End Date</label>
      <input type="date" name="endDate" required value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getEndDate() : "" %>">
    </div>
    <div class="field">
      <label>Registration Start</label>
      <input type="date" name="registrationStart" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getRegistrationStart() : "" %>">
    </div>
    <div class="field">
      <label>Registration End</label>
      <input type="date" name="registrationEnd" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getRegistrationEnd() : "" %>">
    </div>
    <div class="field">
      <label>Exam Start</label>
      <input type="date" name="examStart" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getExamStart() : "" %>">
    </div>
    <div class="field">
      <label>Exam End</label>
      <input type="date" name="examEnd" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getExamEnd() : "" %>">
    </div>
    <div class="field">
      <label>Break Start</label>
      <input type="date" name="breakStart" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getBreakStart() : "" %>">
    </div>
    <div class="field">
      <label>Break End</label>
      <input type="date" name="breakEnd" value="<%= request.getAttribute("editSemester") != null ? ((Semester)request.getAttribute("editSemester")).getBreakEnd() : "" %>">
    </div>
    <div class="field">
      <label>Current Semester</label>
      <div class="pill">
        <input type="checkbox" name="isCurrent" id="isCurrent" <%= request.getAttribute("editSemester") != null && ((Semester)request.getAttribute("editSemester")).isCurrent() ? "checked" : "" %>>
        <span>Set as current semester</span>
      </div>
    </div>
    <div class="field">
      <label>Active</label>
      <div class="pill">
        <input type="checkbox" name="isActive" id="isActive" checked <%= request.getAttribute("editSemester") != null && !((Semester)request.getAttribute("editSemester")).isActive() ? "" : "checked" %>>
        <span>Active</span>
      </div>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/academic/semesters?academicYearId=<%= request.getParameter("academicYearId") %>">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>