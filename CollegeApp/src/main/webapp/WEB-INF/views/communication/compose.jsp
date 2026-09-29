<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*" %>
<% request.setAttribute("pageTitle", "Compose Message"); %>
<%@ include file="../layout/top.jsp" %>
<div class="card">
  <h2>Compose Message</h2>
  <form method="post" action="${pageContext.request.contextPath}/messages/send" class="form-grid">
    ${csrfField}
    <div class="field">
      <label>Recipient *</label>
      <select name="recipientId" required>
        <option value="">Select Recipient</option>
      </select>
    </div>
    <div class="field">
      <label>Subject *</label>
      <input type="text" name="subject" required placeholder="Subject">
    </div>
    <div class="field">
      <label>Message Type</label>
      <select name="messageType">
        <option value="PRIVATE">Private</option>
        <option value="SYSTEM">System</option>
      </select>
    </div>
    <div class="field">
      <label>Priority</label>
      <select name="priority">
        <option value="NORMAL">Normal</option>
        <option value="HIGH">High</option>
        <option value="URGENT">Urgent</option>
        <option value="LOW">Low</option>
      </select>
    </div>
    <div class="field full">
      <label>Body *</label>
      <textarea name="body" required rows="6" placeholder="Write your message..."></textarea>
    </div>
    <div class="form-actions full">
      <button type="submit" class="btn btn-primary"><span class="lbl-txt">Send</span></button>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/messages/inbox">Cancel</a>
    </div>
  </form>
</div>
<%@ include file="../layout/bottom.jsp" %>