<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Scholarships"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Scholarship> items = ViewHelper.<Scholarship>list(request, "scholarships");
%>
<div class="card">
  <h2>Scholarships
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/fee/scholarship-form">+ Add Scholarship</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Name</th><th data-sort>Code</th><th data-sort>Type</th>
      <th data-sort>Value</th><th data-sort>Max Recipients</th><th data-sort>Year</th>
      <th data-sort>Window</th><th style="width:110px">Actions</th>
    </tr>
    <% for (Scholarship s : items) { %>
    <tr>
      <td><b><%= s.getName() %></b></td>
      <td><%= s.getCode() %></td>
      <td><%= s.getAmountType() %></td>
      <td><b><%= "PERCENTAGE".equalsIgnoreCase(String.valueOf(s.getAmountType()))
            ? s.getAmountValue() + "%" : String.format("%,.0f", s.getAmountValue()) %></b></td>
      <td><%= s.getMaxRecipients() %></td>
      <td><%= s.getAcademicYearName() != null ? s.getAcademicYearName() : "—" %></td>
      <td><small><%= s.getApplicationStart() %> → <%= s.getApplicationEnd() %></small></td>
      <td>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/fee/scholarship-form?edit=<%= s.getId() %>">Edit</a>
      </td>
    </tr>
    <% } %>
    <% if (items.isEmpty()) { %><tr><td colspan="8" class="empty">No scholarships defined yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
