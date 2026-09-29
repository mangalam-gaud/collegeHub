<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Fee Payments"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<FeePayment> items = ViewHelper.<FeePayment>list(request, "payments");
%>
<div class="card">
  <h2>Fee Payments
    <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/fee/payment-form">+ Record Payment</a></h2>
  <div class="table-wrap"><table>
    <tr>
      <th data-sort>Receipt</th><th data-sort>Student</th><th data-sort>Structure</th>
      <th data-sort>Date</th><th data-sort>Amount</th><th data-sort>Mode</th>
      <th data-sort>Ref</th><th data-sort>Status</th><th data-sort>Received By</th>
    </tr>
    <% for (FeePayment p : items) { %>
    <tr>
      <td><b><%= p.getReceiptNumber() %></b></td>
      <td><%= p.getStudentName() %> <small>(<%= p.getStudentUsername() %>)</small></td>
      <td><%= p.getFeeStructureName() != null ? p.getFeeStructureName() : "—" %></td>
      <td><%= p.getPaymentDate() %></td>
      <td><b><%= String.format("%,.2f", p.getAmountPaid()) %></b></td>
      <td><%= p.getPaymentMode() %></td>
      <td><%= p.getTransactionRef() != null ? p.getTransactionRef() : "—" %></td>
      <td><span class="badge <%= "PAID".equalsIgnoreCase(String.valueOf(p.getStatus())) ? "badge-on"
              : ("PENDING".equalsIgnoreCase(String.valueOf(p.getStatus())) ? "badge-teacher" : "badge-off") %>"><%= p.getStatus() %></span></td>
      <td><%= p.getReceivedByName() != null ? p.getReceivedByName() : "—" %></td>
    </tr>
    <% } %>
    <% if (items.isEmpty()) { %><tr><td colspan="9" class="empty">No fee payments recorded yet.</td></tr><% } %>
  </table></div>
</div>
<%@ include file="../layout/bottom.jsp" %>
