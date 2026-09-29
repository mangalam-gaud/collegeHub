<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Room Form"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2><%= request.getAttribute("editRoom") != null ? "Edit Room" : "Add Room" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/hostel/room-save" class="form-grid">
    ${csrfField}
    <input type="hidden" name="hostelId" value="<%= request.getParameter("hostelId") != null ? request.getParameter("hostelId") : (request.getAttribute("editRoom") != null ? ((HostelRoom)request.getAttribute("editRoom")).getHostelId() : "") %>">
    <% if (request.getAttribute("editRoom") != null) { %>
      <input type="hidden" name="id" value="<%= ((HostelRoom)request.getAttribute("editRoom")).getId() %>">
    <% } %>
    <div class="field">
      <label>Room Number *</label>
      <input type="text" name="roomNumber" required value="<%= request.getAttribute("editRoom") != null ? ((HostelRoom)request.getAttribute("editRoom")).getRoomNumber() : "" %>" placeholder="e.g., 101">
    </div>
    <div class="field">
      <label>Floor</label>
      <input type="number" name="floor" min="0" value="<%= request.getAttribute("editRoom") != null ? ((HostelRoom)request.getAttribute("editRoom")).getFloor() : "0" %>">
    </div>
    <div class="field">
      <label>Room Type *</label>
      <select name="roomType" required>
        <option value="SINGLE" <%= request.getAttribute("editRoom") != null && "SINGLE".equals(((HostelRoom)request.getAttribute("editRoom")).getRoomType()) ? "selected" : "" %>>Single</option>
        <option value="DOUBLE" <%= request.getAttribute("editRoom") != null && "DOUBLE".equals(((HostelRoom)request.getAttribute("editRoom")).getRoomType()) ? "selected" : "" %>>Double</option>
        <option value="TRIPLE" <%= request.getAttribute("editRoom") != null && "TRIPLE".equals(((HostelRoom)request.getAttribute("editRoom")).getRoomType()) ? "selected" : "" %>>Triple</option>
        <option value="QUAD" <%= request.getAttribute("editRoom") != null && "QUAD".equals(((HostelRoom)request.getAttribute("editRoom")).getRoomType()) ? "selected" : "" %>>Quad</option>
        <option value="DORMITORY" <%= request.getAttribute("editRoom") != null && "DORMITORY".equals(((HostelRoom)request.getAttribute("editRoom")).getRoomType()) ? "selected" : "" %>>Dormitory</option>
      </select>
    </div>
    <div class="field">
      <label>Capacity *</label>
      <input type="number" name="capacity" min="1" required value="<%= request.getAttribute("editRoom") != null ? ((HostelRoom)request.getAttribute("editRoom")).getCapacity() : "2" %>">
    </div>
    <div class="field">
      <label>Rent Per Month</label>
      <input type="number" step="0.01" name="rentPerMonth" value="<%= request.getAttribute("editRoom") != null ? ((HostelRoom)request.getAttribute("editRoom")).getRentPerMonth() : "0" %>">
    </div>
    <div class="field">
      <label>AC</label>
      <div class="pill">
        <input type="checkbox" name="hasAc" id="hasAc" <%= request.getAttribute("editRoom") != null && ((HostelRoom)request.getAttribute("editRoom")).isHasAc() ? "checked" : "" %>>
        <span>Has AC</span>
      </div>
    </div>
    <div class="field">
      <label>Attached Bathroom</label>
      <div class="pill">
        <input type="checkbox" name="hasAttachedBathroom" id="hasAttachedBathroom" <%= request.getAttribute("editRoom") != null && ((HostelRoom)request.getAttribute("editRoom")).isHasAttachedBathroom() ? "checked" : "" %>>
        <span>Attached Bathroom</span>
      </div>
    </div>
    <div class="field full">
      <label>Furniture Details</label>
      <textarea name="furnitureDetails" rows="3"><%= request.getAttribute("editRoom") != null ? ((HostelRoom)request.getAttribute("editRoom")).getFurnitureDetails() : "" %></textarea>
    </div>
    <div class="field">
      <label>Status</label>
      <select name="status">
        <option value="AVAILABLE" <%= request.getAttribute("editRoom") != null && "AVAILABLE".equals(((HostelRoom)request.getAttribute("editRoom")).getStatus()) ? "selected" : "" %>>Available</option>
        <option value="OCCUPIED" <%= request.getAttribute("editRoom") != null && "OCCUPIED".equals(((HostelRoom)request.getAttribute("editRoom")).getStatus()) ? "selected" : "" %>>Occupied</option>
        <option value="PARTIAL" <%= request.getAttribute("editRoom") != null && "PARTIAL".equals(((HostelRoom)request.getAttribute("editRoom")).getStatus()) ? "selected" : "" %>>Partial</option>
        <option value="MAINTENANCE" <%= request.getAttribute("editRoom") != null && "MAINTENANCE".equals(((HostelRoom)request.getAttribute("editRoom")).getStatus()) ? "selected" : "" %>>Maintenance</option>
        <option value="RESERVED" <%= request.getAttribute("editRoom") != null && "RESERVED".equals(((HostelRoom)request.getAttribute("editRoom")).getStatus()) ? "selected" : "" %>>Reserved</option>
      </select>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/hostel/rooms?hostelId=<%= request.getParameter("hostelId") %>">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>