<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Semesters"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Semester> semesters = ViewHelper.<Semester>list(request, "semesters");
String academicYearId = ViewHelper.str(request, "academicYearId");
%>
<div class="card">
  <h2>Semesters
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/academic/semester-form?academicYearId=<%= academicYearId %>">+ Add Semester</a>
    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/academic/academic-years">Back to Academic Years</a>
  </h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Name</th><th data-sort>Number</th><th data-sort>Start</th><th data-sort>End</th><th>Status</th><th style="width:150px">Actions</th></tr>
    <% for (Semester s : semesters) { %>
    <tr>
      <td><b><%= s.getName() %></b></td>
      <td><%= s.getNumber() %></td>
      <td><%= s.getStartDate() %></td>
      <td><%= s.getEndDate() %></td>
      <td><span class="badge <%= s.isCurrent() ? "badge-on" : (s.isActive() ? "badge-student" : "badge-off") %>">
        <%= s.isCurrent() ? "Current" : (s.isActive() ? "Active" : "Inactive") %></span></td>
      <td>
        <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/academic/semester-form?edit=<%= s.getId() %>&academicYearId=<%= academicYearId %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (semesters.isEmpty()) { %><tr><td colspan="6" class="empty">No semesters yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>