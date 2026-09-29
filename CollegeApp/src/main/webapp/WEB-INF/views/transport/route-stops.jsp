<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Route Stops"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<TransportRoute.TransportStop> stops = ViewHelper.<TransportRoute.TransportStop>list(request, "stops");
if (stops == null) stops = new ArrayList<TransportRoute.TransportStop>();
String routeId = request.getParameter("routeId");
%>
<div class="card">
  <h2>Route Stops</h2>
  <form method="get" class="form-grid" style="margin-bottom:18px">
    <div class="field">
      <label for="routeId">Route ID</label>
      <input type="text" id="routeId" name="routeId" value="<%= routeId == null ? "" : routeId %>" placeholder="e.g. 1">
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <button type="submit" class="btn btn-primary" style="width:100%">Load Stops</button>
    </div>
  </form>
  <div class="table-wrap"><table>
    <tr><th data-sort>#</th><th data-sort>Stop</th><th data-sort>Arrival</th><th data-sort>Departure</th><th data-sort>Latitude</th><th data-sort>Longitude</th></tr>
    <% for (TransportRoute.TransportStop s : stops) { %>
    <tr>
      <td><%= s.getStopOrder() %></td>
      <td><b><%= s.getStopName() %></b></td>
      <td><%= s.getArrivalTime() != null ? s.getArrivalTime() : "—" %></td>
      <td><%= s.getDepartureTime() != null ? s.getDepartureTime() : "—" %></td>
      <td><small><%= s.getLatitude() %></small></td>
      <td><small><%= s.getLongitude() %></small></td>
    </tr>
    <% } %>
    <% if (stops.isEmpty()) { %>
    <tr><td colspan="6" class="empty">No stops found. <%= routeId == null || routeId.isEmpty() ? "Enter a Route ID above." : "" %></td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
