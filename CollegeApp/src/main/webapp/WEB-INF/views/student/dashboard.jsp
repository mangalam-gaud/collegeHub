<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.college.model.*, com.college.util.ViewHelper" %>
<% request.setAttribute("pageTitle", "Student Dashboard"); %>
<%@ include file="../layout/top.jsp" %>
<%
List<Course> enrolled = ViewHelper.<Course>list(request, "enrolled");
List<Map<String, Object>> att = (List<Map<String, Object>>) request.getAttribute("attendance");
List<Map<String, Object>> marks = (List<Map<String, Object>>) request.getAttribute("marks");
List<Notice> notices = ViewHelper.<Notice>list(request, "notices");

// overall attendance %
double totalClasses = 0, attended = 0;
for (Map<String, Object> a : att) { totalClasses += (Integer) a.get("total"); attended += (Integer) a.get("attended"); }
double attPct = totalClasses == 0 ? 0 : Math.round(attended * 1000.0 / totalClasses) / 10.0;

// average marks %
double sumPct = 0; int mkCount = 0;
for (Map<String, Object> m : marks) {
    sumPct += (Double) m.get("marks") * 100.0 / (Double) m.get("max"); mkCount++;
}
double avgPct = mkCount == 0 ? 0 : Math.round(sumPct / mkCount * 10.0) / 10.0;
%>
<div class="stats">
  <div class="stat"><div class="num"><%= enrolled.size() %></div><div class="lbl">Enrolled Courses</div></div>
  <div class="stat"><div class="num"><%= attPct %>%</div><div class="lbl">Overall Attendance</div></div>
  <div class="stat"><div class="num"><%= avgPct %>%</div><div class="lbl">Average Score</div></div>
</div>
<div class="grid2">
  <div class="card">
    <h2>My Courses
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/student/courses">Manage</a></h2>
    <% if (enrolled.isEmpty()) { %><div class="empty">You haven't enrolled in any courses yet.</div><% } %>
    <div class="table-wrap"><table>
      <tr><th>Code</th><th>Title</th><th>Teacher</th></tr>
      <% for (Course c : enrolled) { %>
      <tr><td><b><%= c.getCode() %></b></td><td><%= c.getTitle() %></td>
          <td><%= c.getTeacherName() != null ? c.getTeacherName() : "TBA" %></td></tr>
      <% } %>
    </table></div>
  </div>
  <div class="card">
    <h2>📢 Notices</h2>
    <% int shown = 0; for (Notice n : notices) { if (shown++ >= 4) break; %>
      <div class="notice" style="margin-bottom:10px">
        <h3><%= n.getTitle() %></h3>
        <div class="meta"><%= n.getCreatedAt() %></div>
      </div>
    <% } %>
    <% if (notices.isEmpty()) { %><div class="empty">No notices.</div><% } %>
  </div>
</div>
<%@ include file="../layout/bottom.jsp" %>
