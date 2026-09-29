<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Event Form"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2><%= request.getAttribute("editEvent") != null ? "Edit Event" : "Create Event" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/events/event-save" class="form-grid">
    ${csrfField}
    <% if (request.getAttribute("editEvent") != null) { %>
      <input type="hidden" name="id" value="<%= ((Event)request.getAttribute("editEvent")).getId() %>">
    <% } %>
    <div class="field">
      <label>Title *</label>
      <input type="text" name="title" required value="<%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getTitle() : "" %>" placeholder="Event Title">
    </div>
    <div class="field full">
      <label>Description</label>
      <textarea name="description" rows="4"><%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getDescription() : "" %></textarea>
    </div>
    <div class="field">
      <label>Event Type *</label>
      <select name="eventType" required>
        <option value="ACADEMIC" <%= request.getAttribute("editEvent") != null && "ACADEMIC".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Academic</option>
        <option value="CULTURAL" <%= request.getAttribute("editEvent") != null && "CULTURAL".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Cultural</option>
        <option value="SPORTS" <%= request.getAttribute("editEvent") != null && "SPORTS".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Sports</option>
        <option value="SEMINAR" <%= request.getAttribute("editEvent") != null && "SEMINAR".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Seminar</option>
        <option value="WORKSHOP" <%= request.getAttribute("editEvent") != null && "WORKSHOP".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Workshop</option>
        <option value="HOLIDAY" <%= request.getAttribute("editEvent") != null && "HOLIDAY".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Holiday</option>
        <option value="EXAM" <%= request.getAttribute("editEvent") != null && "EXAM".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Exam</option>
        <option value="MEETING" <%= request.getAttribute("editEvent") != null && "MEETING".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Meeting</option>
        <option value="OTHER" <%= request.getAttribute("editEvent") != null && "OTHER".equals(((Event)request.getAttribute("editEvent")).getEventType()) ? "selected" : "" %>>Other</option>
      </select>
    </div>
    <div class="field">
      <label>Start Date/Time *</label>
      <input type="datetime-local" name="startDatetime" required value="<%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getStartDatetime() : "" %>">
    </div>
    <div class="field">
      <label>End Date/Time</label>
      <input type="datetime-local" name="endDatetime" value="<%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getEndDatetime() : "" %>">
    </div>
    <div class="field">
      <label>Location</label>
      <input type="text" name="location" value="<%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getLocation() : "" %>" placeholder="Venue/Room">
    </div>
    <div class="field">
      <label>Target Audience *</label>
      <select name="targetAudience" required>
        <option value="ALL" <%= request.getAttribute("editEvent") != null && "ALL".equals(((Event)request.getAttribute("editEvent")).getTargetAudience()) ? "selected" : "" %>>All</option>
        <option value="STUDENTS" <%= request.getAttribute("editEvent") != null && "STUDENTS".equals(((Event)request.getAttribute("editEvent")).getTargetAudience()) ? "selected" : "" %>>Students</option>
        <option value="TEACHERS" <%= request.getAttribute("editEvent") != null && "TEACHERS".equals(((Event)request.getAttribute("editEvent")).getTargetAudience()) ? "selected" : "" %>>Teachers</option>
        <option value="STAFF" <%= request.getAttribute("editEvent") != null && "STAFF".equals(((Event)request.getAttribute("editEvent")).getTargetAudience()) ? "selected" : "" %>>Staff</option>
      </select>
    </div>
    <div class="field">
      <label>Max Participants</label>
      <input type="number" name="maxParticipants" min="0" value="<%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getMaxParticipants() : "0" %>">
    </div>
    <div class="field">
      <label>Registration Required</label>
      <div class="pill">
        <input type="checkbox" name="registrationRequired" id="registrationRequired" <%= request.getAttribute("editEvent") != null && ((Event)request.getAttribute("editEvent")).isRegistrationRequired() ? "checked" : "" %>>
        <span>Require registration</span>
      </div>
    </div>
    <div class="field">
      <label>Registration Deadline</label>
      <input type="datetime-local" name="registrationDeadline" value="<%= request.getAttribute("editEvent") != null ? ((Event)request.getAttribute("editEvent")).getRegistrationDeadline() : "" %>">
    </div>
    <div class="field">
      <label>Published</label>
      <div class="pill">
        <input type="checkbox" name="isPublished" id="isPublished" checked <%= request.getAttribute("editEvent") != null && !((Event)request.getAttribute("editEvent")).isPublished() ? "" : "checked" %>>
        <span>Published</span>
      </div>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Save</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/events/list">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>