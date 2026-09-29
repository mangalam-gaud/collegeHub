<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Transport Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<TransportRoute> routes = ViewHelper.<TransportRoute>list(request, "routes");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= routes.size() %></div><div class="lbl">Active Routes</div></div>
  <div class="stat"><div class="num"><%= routes.stream().mapToInt(TransportRoute::getStopCount).sum() %></div><div class="lbl">Total Stops</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Routes
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/transport/book-route">+ Book Route</a></h2>
    <% if (routes.isEmpty()) { %><div class="empty">No routes configured.</div><% } %>
    <div class="table-wrap"><table>
      <tr><th data-sort>Name</th><th data-sort>Code</th><th>From</th><th>To</th><th>Distance</th><th>Fee/Month</th><th>Vehicle</th><th style="width:150px">Actions</th></tr>
      <% for (TransportRoute r : routes) { %>
      <tr>
        <td><b><%= r.getName() %></b></td>
        <td><%= r.getCode() %></td>
        <td><%= r.getStartPoint() %></td>
        <td><%= r.getEndPoint() %></td>
        <td><%= r.getDistanceKm() %> km</td>
        <td><%= String.format("%.2f", r.getMonthlyFee()) %></td>
        <td><%= r.getVehicleNumber() != null ? r.getVehicleNumber() : "Unassigned" %></td>
        <td>
          <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/transport/route-stops?routeId=<%= r.getId() %>">Stops</a>
        </td>
      </tr>
      <% } %>
      <% if (routes.isEmpty()) { %><tr><td colspan="8" class="empty">No routes yet.</td></tr><% } %>
    </table></div>
  </div>
  <div class="card">
    <h2>My Bookings
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/transport/book-route">Book Route</a></h2>
    <div class="table-wrap"><table>
      <tr><th>Route</th><th>Stop</th><th>Start Date</th><th>End Date</th><th>Status</th><th>Monthly Fee</th></tr>
      <tr><td colspan="6" class="empty">No bookings yet.</td></tr>
    </table></div>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>