<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Fee Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<div class="stats">
  <div class="stat"><div class="num"><%= request.getAttribute("structureCount") %></div><div class="lbl">Fee Structures</div></div>
  <div class="stat"><div class="num"><%= request.getAttribute("paymentCount") %></div><div class="lbl">Total Payments</div></div>
  <div class="stat"><div class="num"><%= request.getAttribute("scholarshipCount") %></div><div class="lbl">Scholarships</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>Quick Actions</h2>
    <div style="display:flex;gap:10px;flex-wrap:wrap">
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/fee/structure-form">+ Fee Structure</a>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/fee/payment-form">+ Record Payment</a>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/fee/scholarship-form">+ Scholarship</a>
    </div>
  </div>
  <div class="card">
    <h2>Recent Payments</h2>
    <div class="table-wrap"><table>
      <tr><th>Receipt</th><th>Student</th><th>Amount</th><th>Mode</th><th>Date</th><th>Status</th></tr>
      <tr><td colspan="6" class="empty">No recent payments.</td></tr>
    </table></div>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>