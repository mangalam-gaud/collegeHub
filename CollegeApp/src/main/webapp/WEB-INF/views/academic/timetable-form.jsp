<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Timetable Entry"); %>
<%@ include file="../layout/top.jsp" %>
<%
Timetable tt = (Timetable) request.getAttribute("editTimetable");
List<Course> courses = ViewHelper.<Course>list(request, "courses");
List<TimetableSlot> slots = ViewHelper.<TimetableSlot>list(request, "slots");
List<Semester> semesters = ViewHelper.<Semester>list(request, "semesters");
String[] days = {"MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"};
%>
<div class="card">
  <h2><%= tt == null ? "New Timetable Entry" : "Edit Timetable Entry" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/academic/timetable-save" class="form-grid">
    ${csrfField}
    <input type="hidden" name="id" value="<%= tt == null ? "" : tt.getId() %>">
    <div class="field">
      <label for="semesterId">Semester <span aria-hidden="true">*</span></label>
      <select id="semesterId" name="semesterId" required>
        <option value="">Select semester</option>
        <% for (Semester s : semesters) { %>
        <option value="<%= s.getId() %>" <%= tt != null && tt.getSemesterId() == s.getId() ? "selected" : "" %>>
          <%= s.getName() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="courseId">Course <span aria-hidden="true">*</span></label>
      <select id="courseId" name="courseId" required>
        <option value="">Select course</option>
        <% for (Course c : courses) { %>
        <option value="<%= c.getId() %>" <%= tt != null && tt.getCourseId() == c.getId() ? "selected" : "" %>>
          <%= c.getCode() %> — <%= c.getTitle() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="slotId">Time Slot <span aria-hidden="true">*</span></label>
      <select id="slotId" name="slotId" required>
        <option value="">Select slot</option>
        <% for (TimetableSlot sl : slots) { %>
        <option value="<%= sl.getId() %>" <%= tt != null && tt.getSlotId() == sl.getId() ? "selected" : "" %>>
          <%= sl.getName() %> (<%= sl.getStartTime() %>–<%= sl.getEndTime() %>)</option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="room">Room</label>
      <input type="text" id="room" name="room" value="<%= tt == null ? "" : tt.getRoom() %>" placeholder="e.g. A-101">
    </div>
    <div class="field">
      <label for="building">Building</label>
      <input type="text" id="building" name="building" value="<%= tt == null ? "" : tt.getBuilding() %>" placeholder="e.g. Main Block">
    </div>
    <div class="field">
      <label for="effectiveFrom">Effective From</label>
      <input type="date" id="effectiveFrom" name="effectiveFrom" value="<%= tt == null ? "" : tt.getEffectiveFrom() %>">
    </div>
    <div class="field">
      <label for="effectiveTo">Effective To</label>
      <input type="date" id="effectiveTo" name="effectiveTo" value="<%= tt == null ? "" : tt.getEffectiveTo() %>">
    </div>
    <div class="field">
      <label for="isRecurring">Recurring Weekly</label>
      <select id="isRecurring" name="isRecurring">
        <option value="1">Yes</option>
        <option value="0">No</option>
      </select>
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Save Entry</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/academic/timetable-slots">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
