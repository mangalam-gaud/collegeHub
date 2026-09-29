<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Timetable"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Timetable> rows = ViewHelper.<Timetable>list(request, "timetable");
Semester sem = (Semester) request.getAttribute("semester");
String semId = request.getParameter("semId");
String[] days = {"MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"};
%>
<div class="card">
  <h2>Timetable<% if (sem != null) { %> — <%= sem.getName() %><% } %></h2>
  <form method="get" class="form-grid" style="margin-bottom:18px">
    <div class="field">
      <label for="semId">Semester ID</label>
      <input type="text" id="semId" name="semId" value="<%= semId == null ? "" : semId %>" placeholder="e.g. 1">
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <button type="submit" class="btn btn-primary" style="width:100%">Load Timetable</button>
    </div>
    <div class="field">
      <label>&nbsp;</label>
      <a class="btn btn-outline" style="width:100%;display:block;text-align:center"
         href="${pageContext.request.contextPath}/academic/timetable-form">+ Add Entry</a>
    </div>
  </form>

  <% if (semId == null || semId.isEmpty()) { %>
    <div class="empty">Enter a Semester ID above to view its timetable.</div>
  <% } else { %>
  <div class="table-wrap"><table>
    <tr><th data-sort>Day</th><th data-sort>Slot</th><th data-sort>Time</th><th data-sort>Course</th><th data-sort>Room</th><th style="width:180px">Actions</th></tr>
    <% for (Timetable t : rows) { %>
    <tr>
      <td><%= t.getDayOfWeek() %></td>
      <td><%= t.getSlotName() %></td>
      <td><%= t.getStartTime() %> – <%= t.getEndTime() %></td>
      <td><b><%= t.getCourseCode() %></b> <%= t.getCourseTitle() %></td>
      <td><%= t.getRoom() != null ? t.getRoom() : "—" %></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/timetable-form?edit=<%= t.getId() %>">Edit</a>
        <form method="post" action="${pageContext.request.contextPath}/academic/timetable-delete" style="display:inline">
          ${csrfField}
          <input type="hidden" name="id" value="<%= t.getId() %>">
          <input type="hidden" name="semesterId" value="<%= semId %>">
          <button type="submit" class="btn btn-outline btn-sm">Delete</button>
        </form>
      </td>
    </tr>
    <% } %>
    <% if (rows.isEmpty()) { %><tr><td colspan="6" class="empty">No timetable entries for this semester.</td></tr><% } %>
  </table></div>
  <% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>
