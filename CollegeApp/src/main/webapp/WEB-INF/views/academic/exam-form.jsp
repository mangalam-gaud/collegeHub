<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Schedule Exam"); %>
<%
// Declared before the layout include: top.jsp owns the names `me` and `cur`.
Exam ex = (Exam) request.getAttribute("editExam");
List<Course> courses = com.college.util.ViewHelper.<Course>list(request, "courses");
List<Semester> semesters = com.college.util.ViewHelper.<Semester>list(request, "semesters");
String curType = ex == null ? "MIDTERM" : String.valueOf(ex.getExamType());
String curStatus = ex == null ? "SCHEDULED" : String.valueOf(ex.getStatus());
%>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2><%= ex == null ? "Schedule New Exam" : "Edit Exam" %></h2>
  <form method="post" action="${pageContext.request.contextPath}/academic/exam-save" class="form-grid">
    ${csrfField}
    <input type="hidden" name="id" value="<%= ex == null ? "" : ex.getId() %>">
    <div class="field">
      <label for="name">Exam Name <span aria-hidden="true">*</span></label>
      <input type="text" id="name" name="name" required value="<%= ex == null ? "" : ex.getName() %>" placeholder="e.g. Mid-Semester 1">
    </div>
    <div class="field">
      <label for="examType">Type <span aria-hidden="true">*</span></label>
      <select id="examType" name="examType" required>
        <option value="MIDTERM"   <%= "MIDTERM".equals(curType)   ? "selected" : "" %>>Mid-Term</option>
        <option value="FINAL"     <%= "FINAL".equals(curType)     ? "selected" : "" %>>Final</option>
        <option value="QUIZ"      <%= "QUIZ".equals(curType)      ? "selected" : "" %>>Quiz</option>
        <option value="ASSIGNMENT"<%= "ASSIGNMENT".equals(curType)? "selected" : "" %>>Assignment</option>
        <option value="PROJECT"   <%= "PROJECT".equals(curType)   ? "selected" : "" %>>Project</option>
        <option value="PRACTICAL" <%= "PRACTICAL".equals(curType) ? "selected" : "" %>>Practical</option>
        <option value="VIVA"      <%= "VIVA".equals(curType)      ? "selected" : "" %>>Viva</option>
      </select>
    </div>
    <div class="field">
      <label for="courseId">Course <span aria-hidden="true">*</span></label>
      <select id="courseId" name="courseId" required>
        <option value="">Select course</option>
        <% for (Course c : courses) { %>
        <option value="<%= c.getId() %>" <%= ex != null && ex.getCourseId() == c.getId() ? "selected" : "" %>>
          <%= c.getCode() %> — <%= c.getTitle() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="semesterId">Semester <span aria-hidden="true">*</span></label>
      <select id="semesterId" name="semesterId" required>
        <option value="">Select semester</option>
        <% for (Semester s : semesters) { %>
        <option value="<%= s.getId() %>" <%= ex != null && ex.getSemesterId() == s.getId() ? "selected" : "" %>><%= s.getName() %></option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label for="examDate">Exam Date <span aria-hidden="true">*</span></label>
      <input type="date" id="examDate" name="examDate" required value="<%= ex == null ? "" : ex.getExamDate() %>">
    </div>
    <div class="field">
      <label for="startTime">Start Time</label>
      <input type="time" id="startTime" name="startTime" value="<%= ex == null ? "" : ex.getStartTime() %>">
    </div>
    <div class="field">
      <label for="endTime">End Time</label>
      <input type="time" id="endTime" name="endTime" value="<%= ex == null ? "" : ex.getEndTime() %>">
    </div>
    <div class="field">
      <label for="maxMarks">Max Marks</label>
      <input type="number" id="maxMarks" name="maxMarks" min="0" step="0.5" value="<%= ex == null ? "100" : String.valueOf(ex.getMaxMarks()) %>">
    </div>
    <div class="field">
      <label for="passingMarks">Passing Marks</label>
      <input type="number" id="passingMarks" name="passingMarks" min="0" step="0.5" value="<%= ex == null ? "40" : String.valueOf(ex.getPassingMarks()) %>">
    </div>
    <div class="field">
      <label for="room">Room</label>
      <input type="text" id="room" name="room" value="<%= ex == null ? "" : ex.getRoom() %>">
    </div>
    <div class="field">
      <label for="building">Building</label>
      <input type="text" id="building" name="building" value="<%= ex == null ? "" : ex.getBuilding() %>">
    </div>
    <div class="field">
      <label for="status">Status</label>
      <select id="status" name="status">
        <option value="SCHEDULED" <%= "SCHEDULED".equals(curStatus) ? "selected" : "" %>>Scheduled</option>
        <option value="ONGOING"   <%= "ONGOING".equals(curStatus)   ? "selected" : "" %>>Ongoing</option>
        <option value="COMPLETED" <%= "COMPLETED".equals(curStatus) ? "selected" : "" %>>Completed</option>
        <option value="CANCELLED" <%= "CANCELLED".equals(curStatus) ? "selected" : "" %>>Cancelled</option>
        <option value="POSTPONED" <%= "POSTPONED".equals(curStatus) ? "selected" : "" %>>Postponed</option>
      </select>
    </div>
    <div class="field" style="grid-column:1/-1">
      <label for="instructions">Instructions</label>
      <textarea id="instructions" name="instructions" rows="3"><%= ex == null ? "" : ex.getInstructions() %></textarea>
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Save Exam</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/academic/exams">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>
