<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Manage Departments"); %>
<%@ include file="../layout/top.jsp" %>
<% if (request.getAttribute("error") != null) { %>
  <div class="alert alert-error"><%= request.getAttribute("error") %></div>
<% } %>
<div class="card">
  <h2>Departments <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/admin/department-form">+ Add Department</a></h2>
  <div class="table-wrap"><table>
    <tr><th data-sort>Name</th><th data-sort>Code</th><th>HOD</th><th style="width:150px">Actions</th></tr>
    <% List<Department> departments = ViewHelper.<Department>list(request, "departments");
       if (departments != null) {
         for (Department d : departments) { %>
    <tr>
      <td><b><%= d.getName() %></b></td>
      <td><%= d.getCode() %></td>
      <td><%= d.getHodName() != null ? d.getHodName() : "Unassigned" %></td>
      <td>
        <a class="btn btn-outline btn-sm" href="<%= request.getContextPath() %>/admin/department-form?edit=<%= d.getId() %>">Edit</a>
      </td>
    </tr>
    <% } } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>