<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Scholarship"); %>
<%@ include file="../layout/top.jsp" %>
<%
Scholarship s = (Scholarship) request.getAttribute("editScholarship");
List<AcademicYear> years = ViewHelper.<AcademicYear>list(request, "academicYears");
%>
<div class="card">
  <h2><%= s == null ? "New Scholarship" : "Edit Scholarship" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/fee/scholarship-save" class="form-grid">
    ${csrfField}
    <input type="hidden" name="id" value="<%= s == null ? "" : s.getId() %>">
    <div class="field">
      <label for="name">Name <span aria-hidden="true">*</span></label>
      <input type="text" id="name" name="name" required value="<%= s == null ? "" : s.getName() %>" placeholder="e.g. Merit Scholarship">
    </div>
    <div class="field">
      <label for="code">Code <span aria-hidden="true">*</span></label>
      <input type="text" id="code" name="code" required value="<%= s == null ? "" : s.getCode() %>" placeholder="e.g. MERIT">
    </div>
    <div class="field">
      <label for="description">Description</label>
      <textarea id="description" name="description" rows="2"><%= s == null ? "" : s.getDescription() %></textarea>
    </div>
    <div class="field">
      <label for="eligibilityCriteria">Eligibility Criteria</label>
      <textarea id="eligibilityCriteria" name="eligibilityCriteria" rows="2"><%= s == null ? "" : s.getEligibilityCriteria() %></textarea>
    </div>
    <div class="field">
      <label for="amountType">Amount Type <span aria-hidden="true">*</span></label>
      <select id="amountType" name="amountType" required>
        <% String at = s == null ? "PERCENTAGE" : String.valueOf(s.getAmountType()); %>
        <option value="PERCENTAGE" <%= "PERCENTAGE".equals(at) ? "selected" : "" %>>Tuition Percentage</option>
        <option value="FIXED"      <%= "FIXED".equals(at)      ? "selected" : "" %>>Fixed Amount</option>
        <option value="FULL"       <%= "FULL".equals(at)       ? "selected" : "" %>>Full Fees</option>
      </select>
    </div>
    <div class="field">
      <label for="amountValue">Value <span aria-hidden="true">*</span></label>
      <input type="number" id="amountValue" name="amountValue" required min="0" step="0.01"
             value="<%= s == null ? "" : String.valueOf(s.getAmountValue()) %>">
    </div>
    <div class="field">
      <label for="maxRecipients">Max Recipients</label>
      <input type="number" id="maxRecipients" name="maxRecipients" min="0" value="<%= s == null ? "" : String.valueOf(s.getMaxRecipients()) %>">
    </div>
    <div class="field">
      <label for="academicYearId">Academic Year</label>
      <select id="academicYearId" name="academicYearId">
        <option value="">Any year</option>
        <% for (AcademicYear y : years) { %>
        <option value="<%= y.getId() %>" <%= s != null && s.getAcademicYearId() == y.getId() ? "selected" : "" %>><%= y.getName() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="applicationStart">Applications Open</label>
      <input type="date" id="applicationStart" name="applicationStart" value="<%= s == null ? "" : s.getApplicationStart() %>">
    </div>
    <div class="field">
      <label for="applicationEnd">Applications Close</label>
      <input type="date" id="applicationEnd" name="applicationEnd" value="<%= s == null ? "" : s.getApplicationEnd() %>">
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Save Scholarship</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/fee/scholarships">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
