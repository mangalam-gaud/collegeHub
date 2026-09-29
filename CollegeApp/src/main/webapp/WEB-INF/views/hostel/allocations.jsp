<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Hostel Allocations"); %>
<%@ include file="../layout/top.jsp" %>
<%
@SuppressWarnings("unchecked")
List<HostelRoom> allocations = ViewHelper.<HostelRoom>list(request, "allocations");
// `me` (the signed-in User) is already in scope from layout/top.jsp.
boolean isWarden = me != null && ("ADMIN".equals(me.getRole()) || "HOSTEL_WARDEN".equals(me.getRole()));
%>
<div class="card">
  <h2><%= isWarden ? "All Room Allocations" : "My Room Allocation" %>
    <% if (isWarden) { %>
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/hostel/allocate">+ Allocate Room</a>
    <% } %></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Hostel</th><th data-sort>Room</th><th data-sort>Floor</th>
      <th data-sort>Type</th><th data-sort>Beds</th><th data-sort>Monthly Rent</th><th>Status</th>
    </tr>
    <% for (HostelRoom r : allocations) { %>
    <tr>
      <td><b><%= r.getHostelName() %></b></td>
      <td><b><%= r.getRoomNumber() %></b></td>
      <td><%= r.getFloor() %></td>
      <td><%= r.getRoomType() %></td>
      <td><%= r.getOccupiedBeds() %> / <%= r.getCapacity() %></td>
      <td><%= String.format("%,.0f", r.getRentPerMonth()) %></td>
      <td><span class="badge <%= r.getAvailableBeds() > 0 ? "badge-on" : "badge-teacher" %>"><%= r.getStatus() %></span></td>
    </tr>
    <% } %>
    <% if (allocations.isEmpty()) { %>
    <tr><td colspan="7" class="empty">
      <%= isWarden ? "No room allocations recorded yet."
                   : "You have no hostel room allocated. Contact the hostel warden." %>
    </td></tr>
    <% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
