<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "My Fees"); %>
<%@ include file="../layout/top.jsp" %>
<%
FeeStructure fs = (FeeStructure) request.getAttribute("feeStructure");
List<FeePayment> payments = ViewHelper.<FeePayment>list(request, "payments");
Double totalPaid = (Double) request.getAttribute("totalPaid");
Double balance = (Double) request.getAttribute("balance");
%>
<div class="stats">
  <div class="stat"><div class="num"><%= fs != null ? String.format("%.2f", fs.getTotalFee()) : "0.00" %></div><div class="lbl">Total Fee</div></div>
  <div class="stat"><div class="num"><%= totalPaid != null ? String.format("%.2f", totalPaid) : "0.00" %></div><div class="lbl">Paid</div></div>
  <div class="stat"><div class="num"><%= balance != null ? String.format("%.2f", Math.max(0, balance)) : "0.00" %></div><div class="lbl">Balance</div></div>
</div>
<% if (fs != null) { %>
<div class="card">
  <h2>Fee Structure: <%= fs.getName() %></h2>
  <div class="table-wrap"><table>
    <tr><th>Component</th><th>Amount</th></tr>
    <tr><td>Tuition Fee</td><td><%= String.format("%.2f", fs.getTuitionFee()) %></td></tr>
    <tr><td>Lab Fee</td><td><%= String.format("%.2f", fs.getLabFee()) %></td></tr>
    <tr><td>Library Fee</td><td><%= String.format("%.2f", fs.getLibraryFee()) %></td></tr>
    <tr><td>Sports Fee</td><td><%= String.format("%.2f", fs.getSportsFee()) %></td></tr>
    <tr><td>Exam Fee</td><td><%= String.format("%.2f", fs.getExamFee()) %></td></tr>
    <tr><td>Development Fee</td><td><%= String.format("%.2f", fs.getDevelopmentFee()) %></td></tr>
    <tr><td>Hostel Fee</td><td><%= String.format("%.2f", fs.getHostelFee()) %></td></tr>
    <tr><td>Transport Fee</td><td><%= String.format("%.2f", fs.getTransportFee()) %></td></tr>
    <tr><td>Misc Fee</td><td><%= String.format("%.2f", fs.getMiscFee()) %></td></tr>
    <tr style="font-weight:bold;background:var(--gray-100)"><td>Total</td><td><%= String.format("%.2f", fs.getTotalFee()) %></td></tr>
  </table></div>
  <div style="margin-top:16px">
    <span class="badge <%= balance != null && balance <= 0 ? "badge-on" : "badge-off" %>">
      <%= balance != null && balance <= 0 ? "Fully Paid" : "Balance Due" %>
    </span>
    <% if (balance != null && balance > 0) { %>
    <span style="margin-left:12px;color:var(--gray-600)">Due: <%= fs.getDueDate() %></span>
    <a class="btn btn-primary btn-sm" style="margin-left:12px" href="${pageContext.request.contextPath}/fee/payment-form?studentId=<%= request.getSession().getAttribute("user") != null ? ((com.college.model.User)request.getSession().getAttribute("user")).getId() : 0 %>">Pay Now</a>
    <% } %>
  </div>
</div>
<div class="card">
  <h2>Payment History</h2>
  <% if (payments.isEmpty()) { %><div class="empty">No payments yet.</div><% } %>
  <div class="table-wrap"><table>
    <tr><th data-sort>Receipt</th><th data-sort>Date</th><th data-sort>Amount</th><th data-sort>Mode</th><th>Late Fee</th><th>Discount</th><th>Status</th></tr>
    <% for (FeePayment p : payments) { %>
    <tr>
      <td><b><%= p.getReceiptNumber() %></b></td>
      <td><%= p.getPaymentDate() %></td>
      <td><%= String.format("%.2f", p.getAmountPaid()) %></td>
      <td><%= p.getPaymentMode() %></td>
      <td><%= p.getLateFee() > 0 ? String.format("%.2f", p.getLateFee()) : "-" %></td>
      <td><%= p.getDiscount() > 0 ? String.format("%.2f", p.getDiscount()) : "-" %></td>
      <td><span class="badge <%= "COMPLETED".equals(p.getStatus()) ? "badge-on" : "badge-off" %>"><%= p.getStatus() %></span></td>
    </tr>
    <% } %>
  </table></div>
</div>
<% } else { %>
<div class="card"><div class="empty">No fee structure assigned for your program/semester.</div></div>
<% } %>
<%@ include file="../layout/bottom.jsp" %>