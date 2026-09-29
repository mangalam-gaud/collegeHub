<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Fee Structures"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<FeeStructure> items = ViewHelper.<FeeStructure>list(request, "structures");
%>
<div class="card">
  <h2>Fee Structures
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/fee/structure-form">+ Add Fee Structure</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Name</th><th data-sort>Program</th><th data-sort>Sem</th><th data-sort>Category</th>
      <th data-sort>Year</th><th data-sort>Tuition</th><th data-sort>Total</th><th data-sort>Due</th><th style="width:120px">Actions</th>
    </tr>
    <% for (FeeStructure f : items) { %>
    <tr>
      <td><b><%= f.getName() %></b></td>
      <td><%= f.getProgramName() != null ? f.getProgramName() : "—" %></td>
      <td><%= f.getSemester() %></td>
      <td><%= f.getCategory() %></td>
      <td><%= f.getAcademicYearName() != null ? f.getAcademicYearName() : "—" %></td>
      <td><%= String.format("%,.0f", f.getTuitionFee()) %></td>
      <td><b><%= String.format("%,.0f", f.getTotalFee()) %></b></td>
      <td><%= f.getDueDate() %></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/fee/structure-form?edit=<%= f.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (items.isEmpty()) { %><tr><td colspan="9" class="empty">No fee structures defined yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
