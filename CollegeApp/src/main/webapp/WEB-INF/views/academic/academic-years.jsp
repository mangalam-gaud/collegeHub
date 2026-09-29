<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Academic Years"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<AcademicYear> years = ViewHelper.<AcademicYear>list(request, "academicYears");
%>
<div class="card">
  <h2>Academic Years
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/academic/academic-year-form">+ Add Academic Year</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Name</th><th data-sort>Start</th><th data-sort>End</th><th>Semesters</th><th style="width:260px">Actions</th></tr>
    <% for (AcademicYear y : years) { %>
    <tr>
      <td><b><%= y.getName() %></b></td>
      <td><%= y.getStartDate() %></td>
      <td><%= y.getEndDate() %></td>
      <td><a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/semesters?ayId=<%= y.getId() %>">View Semesters</a></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/academic-year-form?edit=<%= y.getId() %>">Edit</a>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/semester-form?ayId=<%= y.getId() %>">+ Semester</a>
      </td>
    </tr>
    <% } %>
    <% if (years.isEmpty()) { %><tr><td colspan="5" class="empty">No academic years yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
