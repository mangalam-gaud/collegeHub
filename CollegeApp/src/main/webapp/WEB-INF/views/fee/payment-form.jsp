<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Record Fee Payment"); %>
<%@ include file="../layout/top.jsp" %>
<%
User student = (User) request.getAttribute("student");
FeeStructure structure = (FeeStructure) request.getAttribute("structure");
%>
<div class="card">
  <h2>Record Fee Payment</h2>
  <form method="post" action="${pageContext.request.contextPath}/fee/payment-save" class="form-grid">
    ${csrfField}
    <div class="field">
      <label for="studentId">Student ID <span aria-hidden="true">*</span></label>
      <input type="number" id="studentId" name="studentId" required min="1"
             value="<%= student == null ? "" : String.valueOf(student.getId()) %>"
             placeholder="e.g. 4">
    </div>
    <div class="field">
      <label for="feeStructureId">Fee Structure ID</label>
      <input type="number" id="feeStructureId" name="feeStructureId" min="1"
             value="<%= structure == null ? "" : String.valueOf(structure.getId()) %>"
             placeholder="Auto-detected if blank">
    </div>
    <div class="field">
      <label for="amountPaid">Amount Paid <span aria-hidden="true">*</span></label>
      <input type="number" id="amountPaid" name="amountPaid" required min="0" step="0.01" value="0.00">
    </div>
    <div class="field">
      <label for="paymentMode">Payment Mode <span aria-hidden="true">*</span></label>
      <select id="paymentMode" name="paymentMode" required>
        <option value="CASH">Cash</option>
        <option value="CARD">Card</option>
        <option value="UPI">UPI</option>
        <option value="NEFT">NEFT</option>
        <option value="RTGS">RTGS</option>
        <option value="CHEQUE">Cheque</option>
        <option value="DD">Demand Draft</option>
        <option value="ONLINE">Online</option>
      </select>
    </div>
    <div class="field">
      <label for="transactionRef">Transaction Ref</label>
      <input type="text" id="transactionRef" name="transactionRef" placeholder="UTR / Cheque no.">
    </div>
    <div class="field">
      <label for="status">Status</label>
      <select id="status" name="status">
        <option value="PAID">Paid</option>
        <option value="PARTIAL">Partial</option>
        <option value="PENDING">Pending</option>
        <option value="REFUNDED">Refunded</option>
      </select>
    </div>
    <div class="field">
      <label for="discount">Discount</label>
      <input type="number" id="discount" name="discount" min="0" step="0.01" value="0.00">
    </div>
    <div class="field">
      <label for="lateFee">Late Fee</label>
      <input type="number" id="lateFee" name="lateFee" min="0" step="0.01" value="0.00">
    </div>
    <div class="field" style="grid-column:1/-1">
      <label for="remarks">Remarks</label>
      <textarea id="remarks" name="remarks" rows="2"></textarea>
    </div>
    <div class="field" style="grid-column:1/-1;display:flex;gap:10px;align-items:center">
      <button type="submit" class="btn btn-primary">Record Payment</button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/fee/payments">Cancel</a>
    </div>
  </form>
  <% if (structure != null) { %>
  <div class="notice" style="margin-top:18px">
    <h3>Applicable structure: <%= structure.getName() %></h3>
    <p>Total payable <b><%= String.format("%,.2f", structure.getTotalFee()) %></b> · due <%= structure.getDueDate() %></p>
  </div>
  <% } %>
</div>
<%@ include file="../layout/bottom.jsp" %>
