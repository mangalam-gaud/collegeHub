<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "New Grievance"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2>Submit Grievance</h2>
  <form method="post" action="${pageContext.request.contextPath}/grievance/submit" class="form-grid">
    ${csrfField}
    <div class="field">
      <label>Category *</label>
      <select name="category" required>
        <option value="">Select Category</option>
        <option value="ACADEMIC">Academic</option>
        <option value="ADMINISTRATIVE">Administrative</option>
        <option value="FACILITIES">Facilities</option>
        <option value="HOSTEL">Hostel</option>
        <option value="TRANSPORT">Transport</option>
        <option value="LIBRARY">Library</option>
        <option value="HARASSMENT">Harassment</option>
        <option value="DISCRIMINATION">Discrimination</option>
        <option value="OTHER">Other</option>
      </select>
    </div>
    <div class="field">
      <label>Subject *</label>
      <input type="text" name="subject" required placeholder="Brief summary of grievance">
    </div>
    <div class="field full">
      <label>Description *</label>
      <textarea name="description" required rows="5" placeholder="Describe your grievance in detail..."></textarea>
    </div>
    <div class="field">
      <label>Priority</label>
      <select name="priority">
        <option value="LOW">Low</option>
        <option value="NORMAL" selected>Normal</option>
        <option value="HIGH">High</option>
        <option value="URGENT">Urgent</option>
      </select>
    </div>
    <div class="field">
      <label>Anonymous</label>
      <div class="pill">
        <input type="checkbox" name="isAnonymous" id="isAnonymous">
        <span>Submit anonymously</span>
      </div>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Submit Grievance</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/grievance/dashboard">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>