<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Timetable Slots"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<TimetableSlot> slots = ViewHelper.<TimetableSlot>list(request, "slots");
%>
<div class="card">
  <h2>Timetable Slots <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/academic/timetable-slot-form">+ Add Slot</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Name</th><th data-sort>Day</th><th data-sort>Start</th><th data-sort>End</th><th>Order</th><th>Break</th><th style="width:150px">Actions</th></tr>
    <% for (TimetableSlot ts : slots) { %>
    <tr>
      <td><b><%= ts.getName() %></b></td>
      <td><%= ts.getDayOfWeek() %></td>
      <td><%= ts.getStartTime() %></td>
      <td><%= ts.getEndTime() %></td>
      <td><%= ts.getSlotOrder() %></td>
      <td><span class="badge <%= ts.isBreak() ? "badge-on" : "badge-off" %>"><%= ts.isBreak() ? "Yes" : "No" %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/academic/timetable-slot-form?edit=<%= ts.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (slots.isEmpty()) { %><tr><td colspan="7" class="empty">No time slots defined.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>