<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Book Transport Route"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<TransportRoute> routes = ViewHelper.<TransportRoute>list(request, "routes");
%>
<div class="card">
  <h2>Book a Transport Route</h2>
  <form method="post" action="${pageContext.request.contextPath}/transport/book-route" class="form-grid">
    ${csrfField}
    <div class="field">
      <label>Route *</label>
      <select name="routeId" required>
        <option value="">Select Route</option>
        <% for (TransportRoute r : routes) { %>
        <option value="<%= r.getId() %>"><%= r.getName() %> (<%= r.getCode() %>) - <%= r.getStartPoint() %> to <%= r.getEndPoint() %> - ₹<%= String.format("%.2f", r.getMonthlyFee()) %>/month</option>
        <% } %>
      </select>
    </div>
    <div class="field">
      <label>Stop *</label>
      <select name="stopId" required>
        <option value="">Select Stop</option>
      </select>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Book Route</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/transport/bookings">Cancel</a>
    </div>
  </form>
</div>
<script>
document.querySelector('select[name="routeId"]').addEventListener('change', function() {
  var routeId = this.value;
  var stopSelect = document.querySelector('select[name="stopId"]');
  stopSelect.innerHTML = '<option value="">Select Stop</option>';
  if (routeId) {
    fetch('${pageContext.request.contextPath}/api/transport/stops?routeId=' + routeId)
      .then(r => r.json())
      .then(data => {
        data.forEach(s => {
          var opt = document.createElement('option');
          opt.value = s.id;
          opt.textContent = s.stopName + ' (' + s.arrivalTime + ')';
          stopSelect.appendChild(opt);
        });
      });
  }
});
</script>
<%@ include file="../layout/bottom.jsp" %>