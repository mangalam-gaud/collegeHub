<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Hostels"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Hostel> hostels = ViewHelper.<Hostel>list(request, "hostels");
%>
<div class="card">
  <h2>Hostels <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/hostel/hostel-form">+ Add Hostel</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Name</th><th data-sort>Code</th><th data-sort>Type</th><th>Rooms</th><th>Beds</th><th>Warden</th><th style="width:150px">Actions</th></tr>
    <% for (Hostel h : hostels) { %>
    <tr>
      <td><b><%= h.getName() %></b></td>
      <td><%= h.getCode() %></td>
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
    <% if (hostels.isEmpty()) { %><tr><td colspan="7" class="empty">No hostels yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>