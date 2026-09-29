<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>403 - Forbidden — Mangaud CollegeHub</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="auth-wrap" style="background:linear-gradient(140deg,#1e1b4b 0%,#312e81 42%,#4f46e5 74%,#f59e0b 100%);">
  <div class="auth-card" style="max-width:500px;text-align:center">
    <div class="auth-logo"><img src="${pageContext.request.contextPath}/img/logo.svg" alt="" width="52" height="52"></div>
    <h1>403</h1>
    <h2 style="font-size:28px;margin:16px 0">Access Forbidden</h2>
    <p style="color:var(--gray-600);margin-bottom:24px">You don't have permission to access this resource.</p>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-primary">Go to Login</a>
    <a href="${pageContext.request.contextPath}/" class="btn btn-outline" style="margin-left:12px">Home</a>
  </div>
</div>
</body>
</html>