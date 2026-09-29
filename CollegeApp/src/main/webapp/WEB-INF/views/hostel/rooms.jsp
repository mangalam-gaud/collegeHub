<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Rooms"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<HostelRoom> rooms = ViewHelper.<HostelRoom>list(request, "rooms");
String hostelId = ViewHelper.str(request, "hostelId");
%>
<div class="card">
  <h2>Rooms
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/hostel/room-form?hostelId=<%= hostelId %>">+ Add Room</a>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/hostel/hostels">Back to Hostels</a>
  </h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Room No</th><th data-sort>Floor</th><th>Type</th><th>Capacity</th><th>Occupied</th><th>Rent</th><th>Status</th><th style="width:150px">Actions</th></tr>
    <% for (HostelRoom r : rooms) { %>
    <tr>
      <td><b><%= r.getRoomNumber() %></b></td>
      <td><%= r.getFloor() %></td>
      <td><span class="badge badge-teacher"><%= r.getRoomType() %></span></td>
      <td><%= r.getCapacity() %></td>
      <td><%= r.getOccupiedBeds() %> / <%= r.getCapacity() %></td>
      <td><%= String.format("%.2f", r.getRentPerMonth()) %></td>
      <td><span class="badge <%= "AVAILABLE".equals(r.getStatus()) ? "badge-on" : ("OCCUPIED".equals(r.getStatus()) ? "badge-off" : "badge-teacher") %>"><%= r.getStatus() %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/hostel/room-form?edit=<%= r.getId() %>&hostelId=<%= hostelId %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (rooms.isEmpty()) { %><tr><td colspan="8" class="empty">No rooms yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>