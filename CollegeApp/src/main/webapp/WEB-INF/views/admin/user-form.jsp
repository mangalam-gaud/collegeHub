<%@ page import="com.college.util.ViewHelper" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.college.model.User" %>
<%
User editUser = (User) request.getAttribute("editUser");
String formRole = ViewHelper.str(request, "formRole");
if (editUser != null) formRole = editUser.getRole();
request.setAttribute("pageTitle", editUser != null ? "Edit " + formRole : "Add " + formRole);
%>
<%@ include file="../layout/top.jsp" %>
<% if (request.getAttribute("error") != null) { %>
  <div class="alert alert-error"><%= request.getAttribute("error") %></div>
<% } %>
<div class="card" style="max-width:720px">
  <h2><%= editUser != null ? "Edit User" : "New " + formRole %></h2>
  <form method="post" action="${pageContext.request.contextPath}/admin/user-save" id="userForm">
    ${csrfField}
    <% if (editUser != null) { %><input type="hidden" name="id" value="<%= editUser.getId() %>"><% } %>
    <input type="hidden" name="role" value="<%= formRole %>">
    <div class="form-grid">
      <div class="field"><label>Full Name *</label>
        <input name="fullName" required value="<%= editUser != null ? editUser.getFullName() : "" %>"></div>
      <div class="field"><label>Username *</label>
        <input name="username" required <%= editUser != null ? "disabled" : "" %>
               value="<%= editUser != null ? editUser.getUsername() : "" %>"
               pattern="[a-zA-Z0-9._]{3,50}"></div>
      <div class="field"><label>Email *</label>
        <input type="email" name="email" required value="<%= editUser != null ? editUser.getEmail() : "" %>"></div>
      <div class="field"><label>Phone</label>
        <input name="phone" value="<%= editUser != null && editUser.getPhone() != null ? editUser.getPhone() : "" %>"></div>
      <div class="field"><label>Gender</label>
        <select name="gender">
          <% String g = editUser != null ? editUser.getGender() : null; %>
          <option value="">Select…</option>
          <option <%= "Male".equals(g) ? "selected" : "" %>>Male</option>
          <option <%= "Female".equals(g) ? "selected" : "" %>>Female</option>
          <option <%= "Other".equals(g) ? "selected" : "" %>>Other</option>
        </select></div>
      <div class="field"><label>Date of Birth</label>
        <input type="date" name="dob" value="<%= editUser != null && editUser.getDob() != null ? editUser.getDob() : "" %>"></div>
      <div class="field"><label>Password <%= editUser == null ? "*" : " (leave blank to keep)" %></label>
        <input type="password" name="password" <%= editUser == null ? "required" : "" %> minlength="6" id="pwField">
        <div id="pwStrength" style="font-size:12px;min-height:16px"></div></div>
      <div class="field full"><label>Address</label>
        <input name="address" value="<%= editUser != null && editUser.getAddress() != null ? editUser.getAddress() : "" %>"></div>
    </div>
    <div class="form-actions">
      <button class="btn btn-primary"><span class="lbl-txt"><%= editUser != null ? "Save Changes" : "Create " + formRole %></span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/users">Cancel</a>
    </div>
  </form>
</div>
<script>
  // live password strength meter
  (function () {
    var f = document.getElementById('pwField');
    if (!f) return;
    var label = document.getElementById('pwStrength');
    f.addEventListener('input', function () {
      var v = f.value, score = 0;
      if (v.length >= 6) score++;
      if (v.length >= 10) score++;
      if (/[A-Z]/.test(v) && /[a-z]/.test(v)) score++;
      if (/\d/.test(v)) score++;
      if (/[^A-Za-z0-9]/.test(v)) score++;
      var labels = ['Too short', 'Weak', 'Fair', 'Good', 'Strong', 'Excellent'];
      var colors = ['var(--gray-400)', 'var(--red-500)', 'var(--amber-500)',
                    'var(--primary-600)', 'var(--green-500)', 'var(--green-500)'];
      label.textContent = v ? labels[score] + ' password' : '';
      label.style.color = v ? colors[score] : '';
    });
  })();
</script>
<%@ include file="../layout/bottom.jsp" %>
