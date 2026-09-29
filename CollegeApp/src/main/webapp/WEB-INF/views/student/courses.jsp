<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Courses"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Course> enrolled = ViewHelper.<Course>list(request, "enrolled");
List<Course> available = ViewHelper.<Course>list(request, "available");
%>
<div class="card">
  <h2>My Enrolled Courses (<%= enrolled.size() %>)</h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Code</th><th data-sort>Title</th><th data-sort>Credits</th><th>Teacher</th><th></th></tr>
    <% for (Course c : enrolled) { %>
    <tr>
      <td><b><%= c.getCode() %></b></td><td><%= c.getTitle() %></td>
      <td><%= c.getCredits() %></td>
      <td><%= c.getTeacherName() != null ? c.getTeacherName() : "TBA" %></td>
      <td><form method="post" action="${pageContext.request.contextPath}/student/unenroll"
            onsubmit="return confirm('Unenroll from this course?')">
          ${csrfField}
          <input type="hidden" name="courseId" value="<%= c.getId() %>">
          <button class="btn btn-danger btn-sm"><span class="lbl-txt">Unenroll</span></button></form></td>
    </tr>
    <% } %>
    <% if (enrolled.isEmpty()) { %><tr><td colspan="5" class="empty">Not enrolled in any course.</td></tr><% } %>
  </table></div>
</div>
<div class="card">
  <h2>Available Courses (<%= available.size() %>)</h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Code</th><th data-sort>Title</th><th data-sort>Credits</th><th data-sort>Semester</th><th>Teacher</th><th></th></tr>
    <% for (Course c : available) { %>
    <tr>
      <td><b><%= c.getCode() %></b></td><td><%= c.getTitle() %></td>
      <td><%= c.getCredits() %></td><td><%= c.getSemester() %></td>
      <td><%= c.getTeacherName() != null ? c.getTeacherName() : "TBA" %></td>
      <td><form method="post" action="${pageContext.request.contextPath}/student/enroll">
          ${csrfField}
          <input type="hidden" name="courseId" value="<%= c.getId() %>">
          <button class="btn btn-primary btn-sm"><span class="lbl-txt">Enroll</span></button></form></td>
    </tr>
    <% } %>
    <% if (available.isEmpty()) { %><tr><td colspan="6" class="empty">You're enrolled in everything! 🎉</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
