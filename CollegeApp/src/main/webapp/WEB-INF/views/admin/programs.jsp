<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Manage Programs"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Program> programs = ViewHelper.<Program>list(request, "programs");
%>
<div class="card">
  <h2>Programs <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/admin/program-form">+ Add Program</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Code</th><th data-sort>Name</th><th>Department</th><th>Duration</th><th>Semesters</th><th style="width:150px">Actions</th></tr>
    <% for (Program p : programs) { %>
    <tr>
      <td><b><%= p.getCode() %></b></td>
      <td><%= p.getName() %></td>
      <td><%= p.getDepartmentName() != null ? p.getDepartmentName() : "Unassigned" %></td>
      <td><%= p.getDurationYears() %> years</td>
      <td><%= p.getTotalSemesters() %></td>
      <td>
        <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/admin/program-form?edit=<%= p.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (programs.isEmpty()) { %><tr><td colspan="6" class="empty">No programs yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>