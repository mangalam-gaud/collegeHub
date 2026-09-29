<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "My Profile"); %>
<%@ include file="../layout/top.jsp" %>
<%
User profile = (User) request.getAttribute("profile");
%>
<% if (request.getAttribute("saved") != null) { %>
  <div class="alert alert-success">Profile updated successfully!</div>
<% } %>
<% if (request.getAttribute("pwchanged") != null) { %>
  <div class="alert alert-success">Password changed successfully!</div>
<% } %>
<% if (request.getAttribute("pwerror") != null) { %>
  <div class="alert alert-error">Password must be at least 6 characters.</div>
<% } %>

<div class="grid2">
  <div class="card">
    <h2>Personal Information</h2>
    <form method="post" action="${pageContext.request.contextPath}/student/profile-save" class="form-grid">
      ${csrfField}
      <div class="field">
        <label>Full Name *</label>
        <input type="text" name="fullName" required value="<%= profile.getFullName() %>">
      </div>
      <div class="field">
        <label>Email *</label>
        <input type="email" name="email" required value="<%= profile.getEmail() %>">
      </div>
      <div class="field">
        <label>Phone</label>
        <input type="tel" name="phone" value="<%= profile.getPhone() != null ? profile.getPhone() : "" %>">
      </div>
      <div class="field">
        <label>Gender</label>
        <select name="gender">
          <option value="">Select</option>
          <option value="MALE" <%= "MALE".equals(profile.getGender()) ? "selected" : "" %>>Male</option>
          <option value="FEMALE" <%= "FEMALE".equals(profile.getGender()) ? "selected" : "" %>>Female</option>
          <option value="OTHER" <%= "OTHER".equals(profile.getGender()) ? "selected" : "" %>>Other</option>
        </select>
      </div>
      <div class="field">
        <label>Date of Birth</label>
        <input type="date" name="dob" value="<%= profile.getDob() != null ? profile.getDob() : "" %>">
      </div>
      <div class="field full">
        <label>Address</label>
        <textarea name="address" rows="3"><%= profile.getAddress() != null ? profile.getAddress() : "" %></textarea>
      </div>
      <div class="form-actions full">
        <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save Changes</span></button>
      </div>
    </form>
  </div>

  <div class="card">
    <h2>Account Security</h2>
    <form method="post" action="${pageContext.request.contextPath}/student/password-save" class="form-grid">
      ${csrfField}
      <div class="field">
        <label>New Password *</label>
        <input type="password" name="password" required minlength="6" placeholder="Minimum 6 characters">
      </div>
      <div class="form-actions full">
        <button type="submit" class="btn btn-primary"><span class="lbl-txt">Change Password</span></button>
      </div>
    </form>
  </div>
</div>

<div class="card">
  <h2>Academic Info</h2>
  <div class="table-wrap"><table>
    <tr><th>Student ID</th><th>Program</th><th>Semester</th><th>Admission Date</th><th>Category</th></tr>
    <tr><td><%= profile.getUsername() %></td><td colspan="4">Profile details loaded from student_profiles table</td></tr>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>