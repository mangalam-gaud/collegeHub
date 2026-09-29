<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Fee Structure"); %>
<%@ include file="../layout/top.jsp" %>
<%
FeeStructure f = (FeeStructure) request.getAttribute("editStructure");
List<Program> programs = ViewHelper.<Program>list(request, "programs");
List<AcademicYear> years = ViewHelper.<AcademicYear>list(request, "academicYears");
%>
<div class="card">
  <h2><%= f == null ? "New Fee Structure" : "Edit Fee Structure" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/fee/structure-save" class="form-grid">
    ${csrfField}
    <input type="hidden" name="id" value="<%= f == null ? "" : f.getId() %>">
    <div class="field">
      <label for="name">Name <span aria-hidden="true">*</span></label>
      <input type="text" id="name" name="name" required value="<%= f == null ? "" : f.getName() %>" placeholder="e.g. BCA Sem 1 General">
    </div>
    <div class="field">
      <label for="programId">Program</label>
      <select id="programId" name="programId">
        <option value="">All programs</option>
        <% for (Program p : programs) { %>
        <option value="<%= p.getId() %>" <%= f != null && f.getProgramId() == p.getId() ? "selected" : "" %>><%= p.getName() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="semester">Semester</label>
      <input type="number" id="semester" name="semester" min="0" value="<%= f == null ? "" : String.valueOf(f.getSemester()) %>">
    </div>
    <div class="field">
      <label for="category">Category</label>
      <select id="category" name="category">
        <% String c = f == null ? "GENERAL" : String.valueOf(f.getCategory()); %>
        <option value="GENERAL" <%= "GENERAL".equals(c) ? "selected" : "" %>>General</option>
        <option value="OBC"     <%= "OBC".equals(c)     ? "selected" : "" %>>OBC</option>
        <option value="SC"      <%= "SC".equals(c)      ? "selected" : "" %>>SC</option>
        <option value="ST"      <%= "ST".equals(c)      ? "selected" : "" %>>ST</option>
        <option value="EWS"     <%= "EWS".equals(c)     ? "selected" : "" %>>EWS</option>
      </select>
    </div>
    <div class="field">
      <label for="academicYearId">Academic Year</label>
      <select id="academicYearId" name="academicYearId">
        <option value="">Any year</option>
        <% for (AcademicYear y : years) { %>
        <option value="<%= y.getId() %>" <%= f != null && f.getAcademicYearId() == y.getId() ? "selected" : "" %>><%= y.getName() %></option>
        <% } %>
      </select>
    </div>

    <h3 style="grid-column:1/-1;margin:10px 0 0">Fee Heads</h3>
    <div class="field"><label for="tuitionFee">Tuition Fee</label>
      <input type="number" id="tuitionFee" name="tuitionFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getTuitionFee()) %>"></div>
    <div class="field"><label for="labFee">Lab Fee</label>
      <input type="number" id="labFee" name="labFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getLabFee()) %>"></div>
    <div class="field"><label for="libraryFee">Library Fee</label>
      <input type="number" id="libraryFee" name="libraryFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getLibraryFee()) %>"></div>
    <div class="field"><label for="sportsFee">Sports Fee</label>
      <input type="number" id="sportsFee" name="sportsFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getSportsFee()) %>"></div>
    <div class="field"><label for="examFee">Exam Fee</label>
      <input type="number" id="examFee" name="examFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getExamFee()) %>"></div>
    <div class="field"><label for="developmentFee">Development Fee</label>
      <input type="number" id="developmentFee" name="developmentFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getDevelopmentFee()) %>"></div>
    <div class="field"><label for="hostelFee">Hostel Fee</label>
      <input type="number" id="hostelFee" name="hostelFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getHostelFee()) %>"></div>
    <div class="field"><label for="transportFee">Transport Fee</label>
      <input type="number" id="transportFee" name="transportFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getTransportFee()) %>"></div>
    <div class="field"><label for="miscFee">Misc Fee</label>
      <input type="number" id="miscFee" name="miscFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getMiscFee()) %>"></div>

    <h3 style="grid-column:1/-1;margin:10px 0 0">Payment Terms</h3>
    <div class="field"><label for="dueDate">Due Date</label>
      <input type="date" id="dueDate" name="dueDate" value="<%= f == null ? "" : f.getDueDate() %>"></div>
    <div class="field"><label for="lateFeePerDay">Late Fee / Day</label>
      <input type="number" id="lateFeePerDay" name="lateFeePerDay" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getLateFeePerDay()) %>"></div>
    <div class="field"><label for="maxLateFee">Max Late Fee</label>
      <input type="number" id="maxLateFee" name="maxLateFee" min="0" step="0.01" value="<%= f == null ? "" : String.valueOf(f.getMaxLateFee()) %>"></div>
    <div class="field">
      <label for="isActive">Active</label>
      <select id="isActive" name="isActive">
        <option value="1">Yes</option>
        <option value="0">No</option>
      </select>
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Save Fee Structure</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/fee/structures">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
