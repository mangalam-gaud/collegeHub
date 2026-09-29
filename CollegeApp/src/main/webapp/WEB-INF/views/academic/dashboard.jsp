<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Academic Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
AcademicYear currentAY = (AcademicYear) request.getAttribute("currentAcademicYear");
Semester currentSem = (Semester) request.getAttribute("currentSemester");
List<AcademicYear> academicYears = ViewHelper.<AcademicYear>list(request, "academicYears");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= academicYears.size() %></div><div class="lbl">Academic Years</div></div>
  <div class="stat"><div class="num"><%= currentSem != null ? 1 : 0 %></div><div class="lbl">Active Semester</div></div>
  <div class="stat"><div class="num"><%= currentAY != null ? 1 : 0 %></div><div class="lbl">Current Year</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Current Academic Year
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/academic/academic-years">Manage</a></h2>
    <% if (currentAY != null) { %>
      <div class="notice" style="margin-bottom:10px">
        <h3><%= currentAY.getName() %></h3>
        <div class="meta"><%= currentAY.getStartDate() %> - <%= currentAY.getEndDate() %></div>
      </div>
    <% } else { %><div class="empty">No academic year configured.</div><% } %>
  </div>
  <div class="card">
    <h2>Current Semester
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/academic/semesters">Manage</a></h2>
    <% if (currentSem != null) { %>
      <div class="notice" style="margin-bottom:10px">
        <h3><%= currentSem.getName() %></h3>
        <div class="meta"><%= currentSem.getStartDate() %> - <%= currentSem.getEndDate() %></div>
      </div>
    <% } else { %><div class="empty">No active semester.</div><% } %>
  </div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Quick Actions</h2>
    <div style="display:flex;gap:10px;flex-wrap:wrap">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/academic/academic-year-form">+ Add Academic Year</a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/academic/semester-form">+ Add Semester</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/academic/timetable-slots">Manage Time Slots</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/academic/exams">Manage Exams</a>
    </div>
  </div>
  <div class="card">
    <h2>Academic Years</h2>
    <% if (academicYears.isEmpty()) { %><div class="empty">No academic years yet.</div><% } %>
    <div class="table-wrap"><table>
      <tr><th data-sort>Name</th><th data-sort>Start</th><th data-sort>End</th><th>Status</th><th style="width:150px">Actions</th></tr>
      <% for (AcademicYear ay : academicYears) { %>
      <tr>
        <td><b><%= ay.getName() %></b></td>
        <td><%= ay.getStartDate() %></td>
        <td><%= ay.getEndDate() %></td>
        <td><span class="badge <%= ay.isCurrent() ? "badge-on" : (ay.isActive() ? "badge-student" : "badge-off") %>">
          <%= ay.isCurrent() ? "Current" : (ay.isActive() ? "Active" : "Inactive") %></span></td>
        <td>
          <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/academic/academic-year-form?edit=<%= ay.getId() %>">Edit</a>
        </td>
      </tr>
      <% } %>
    </table></div>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>