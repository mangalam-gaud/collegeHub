<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Hostel Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Hostel> hostels = ViewHelper.<Hostel>list(request, "hostels");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= hostels.size() %></div><div class="lbl">Hostels</div></div>
  <div class="stat"><div class="num"><%= hostels.stream().mapToInt(Hostel::getTotalRooms).sum() %></div><div class="lbl">Total Rooms</div></div>
  <div class="stat"><div class="num"><%= hostels.stream().mapToInt(Hostel::getTotalBeds).sum() %></div><div class="lbl">Total Beds</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Hostels
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/hostel/hostel-form">+ Add Hostel</a></h2>
    <% if (hostels.isEmpty()) { %><div class="empty">No hostels configured.</div><% } %>
    <div class="table-wrap"><table>
      <tr><th data-sort>Name</th><th data-sort>Type</th><th>Rooms</th><th>Beds</th><th>Warden</th><th style="width:150px">Actions</th></tr>
      <% for (Hostel h : hostels) { %>
      <tr>
        <td><b><%= h.getName() %></b></td>
        <td><span class="badge badge-teacher"><%= h.getType() %></span></td>
        <td><%= h.getTotalRooms() %></td>
        <td><%= h.getTotalBeds() %></td>
        <td><%= h.getWardenName() != null ? h.getWardenName() : "Unassigned" %></td>
        <td>
          <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/hostel/rooms?hostelId=<%= h.getId() %>">Rooms</a>
          <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/hostel/hostel-form?edit=<%= h.getId() %>">Edit</a>
        </td>
      </tr>
      <% } %>
    </table></div>
  </div>
  <div class="card">
    <h2>Quick Actions</h2>
    <div style="display:flex;gap:10px;flex-wrap:wrap">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/hostel/hostel-form">+ Add Hostel</a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/hostel/room-form">+ Add Room</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/hostel/allocate">Allocate Room</a>
    </div>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>