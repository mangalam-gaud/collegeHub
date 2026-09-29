<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Transport Bookings"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<TransportRoute> bookings = ViewHelper.<TransportRoute>list(request, "bookings");
%>
<div class="card">
  <h2>Route Bookings
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/transport/book-route">+ Book Route</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Route</th><th data-sort>Code</th><th data-sort>From</th><th data-sort>To</th>
        <th data-sort>Period</th><th data-sort>Status</th><th style="width:150px">Actions</th></tr>
    <% for (TransportRoute b : bookings) { %>
    <tr>
      <td><b><%= b.getName() %></b></td>
      <td><%= b.getCode() %></td>
      <td><%= b.getStartPoint() %></td>
      <td><%= b.getEndPoint() %></td>
      <td><small><%= b.getBookingStartDate() %> → <%= b.getBookingEndDate() %></small></td>
      <td><span class="badge <%= "ACTIVE".equalsIgnoreCase(String.valueOf(b.getBookingStatus())) ? "badge-on"
              : ("CANCELLED".equalsIgnoreCase(String.valueOf(b.getBookingStatus())) ? "badge-off" : "badge-teacher") %>"><%= b.getBookingStatus() %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/transport/route-stops?routeId=<%= b.getId() %>">Stops</a>
      </td>
    </tr>
    <% } %>
    <% if (bookings.isEmpty()) { %>
    <tr><td colspan="7" class="empty">No route bookings yet. <a href="${pageContext.request.contextPath}/transport/book-route">Book a route</a>.</td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
