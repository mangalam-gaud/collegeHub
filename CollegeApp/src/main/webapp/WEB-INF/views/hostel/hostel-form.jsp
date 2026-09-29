<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Hostel Form"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2><%= request.getAttribute("editHostel") != null ? "Edit Hostel" : "Add Hostel" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/hostel/hostel-save" class="form-grid">
    ${csrfField}
    <% if (request.getAttribute("editHostel") != null) { %>
      <input type="hidden" name="id" value="<%= ((Hostel)request.getAttribute("editHostel")).getId() %>">
    <% } %>
    <div class="field">
      <label>Name *</label>
      <input type="text" name="name" required value="<%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getName() : "" %>" placeholder="Hostel Name">
    </div>
    <div class="field">
      <label>Code *</label>
      <input type="text" name="code" required value="<%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getCode() : "" %>" placeholder="e.g., HST001">
    </div>
    <div class="field">
      <label>Type *</label>
      <select name="type" required>
        <option value="BOYS" <%= request.getAttribute("editHostel") != null && "BOYS".equals(((Hostel)request.getAttribute("editHostel")).getType()) ? "selected" : "" %>>Boys</option>
        <option value="GIRLS" <%= request.getAttribute("editHostel") != null && "GIRLS".equals(((Hostel)request.getAttribute("editHostel")).getType()) ? "selected" : "" %>>Girls</option>
        <option value="COED" <%= request.getAttribute("editHostel") != null && "COED".equals(((Hostel)request.getAttribute("editHostel")).getType()) ? "selected" : "" %>>Co-Ed</option>
      </select>
    </div>
    <div class="field">
      <label>Warden</label>
      <select name="wardenId">
        <option value="0">Select Warden</option>
        <% List<User> wardens = ViewHelper.<User>list(request, "wardens");
           if (wardens != null) {
             for (User w : wardens) { %>
        <option value="<%= w.getId() %>" <%= request.getAttribute("editHostel") != null && ((Hostel)request.getAttribute("editHostel")).getWardenId() == w.getId() ? "selected" : "" %>><%= w.getFullName() %></option>
        <% } } %>
      </select>
    </div>
    <div class="field full">
      <label>Address</label>
      <textarea name="address" rows="3"><%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getAddress() : "" %></textarea>
    </div>
    <div class="field">
      <label>Total Rooms</label>
      <input type="number" name="totalRooms" min="0" value="<%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getTotalRooms() : "0" %>">
    </div>
    <div class="field">
      <label>Total Beds</label>
      <input type="number" name="totalBeds" min="0" value="<%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getTotalBeds() : "0" %>">
    </div>
    <div class="field full">
      <label>Facilities</label>
      <textarea name="facilities" rows="3"><%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getFacilities() : "" %></textarea>
    </div>
    <div class="field full">
      <label>Rules</label>
      <textarea name="rules" rows="3"><%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getRules() : "" %></textarea>
    </div>
    <div class="field">
      <label>Contact Phone</label>
      <input type="tel" name="contactPhone" value="<%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getContactPhone() : "" %>">
    </div>
    <div class="field">
      <label>Contact Email</label>
      <input type="email" name="contactEmail" value="<%= request.getAttribute("editHostel") != null ? ((Hostel)request.getAttribute("editHostel")).getContactEmail() : "" %>">
    </div>
    <div class="field">
      <label>Active</label>
      <div class="pill">
        <input type="checkbox" name="isActive" id="isActive" checked <%= request.getAttribute("editHostel") != null && !((Hostel)request.getAttribute("editHostel")).isActive() ? "" : "checked" %>>
        <span>Active</span>
      </div>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/hostel/hostels">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>