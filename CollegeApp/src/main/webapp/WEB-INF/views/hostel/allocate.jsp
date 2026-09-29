<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Allocate Room"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<HostelRoom> rooms = ViewHelper.<HostelRoom>list(request, "rooms");
List<Hostel> hostels = ViewHelper.<Hostel>list(request, "hostels");
List<User> students = ViewHelper.<User>list(request, "students");
%>
<div class="card">
  <h2>Allocate Room to Student</h2>
  <form method="post" action="${pageContext.request.contextPath}/hostel/allocate-room" class="form-grid">
    ${csrfField}
    <div class="field">
      <label for="studentId">Student <span aria-hidden="true">*</span></label>
      <select id="studentId" name="studentId" required>
        <option value="">Select student</option>
        <% for (User u : students) { %>
        <option value="<%= u.getId() %>"><%= u.getFullName() %> (<%= u.getUsername() %>)</option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="roomId">Room <span aria-hidden="true">*</span></label>
      <select id="roomId" name="roomId" required>
        <option value="">Select room</option>
        <% for (HostelRoom r : rooms) { %>
        <option value="<%= r.getId() %>">
          <%= r.getHostelName() %> — Room <%= r.getRoomNumber() %> (<%= r.getAvailableBeds() %> free)</option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="bedNumber">Bed Number</label>
      <input type="text" id="bedNumber" name="bedNumber" placeholder="e.g. A1">
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Allocate</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/hostel/allocations">Cancel</a>
    </div>
  </form>
  <% if (hostels.isEmpty()) { %>
  <div class="empty" style="margin-top:16px">No hostels configured yet.</div>
  <% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>
