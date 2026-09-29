<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.college.filter.SecurityFilter" %>
<%@ page import="com.college.util.DemoLogin" %>
<%
String csrf = SecurityFilter.token(session);
String error = request.getAttribute("error") == null ? "" : request.getAttribute("error").toString();
boolean demo = DemoLogin.isEnabled();
// `styleVersion` is published as a request attribute by SecurityFilter and is
// used to cache-bust the stylesheet below.
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sign in — Mangaud CollegeHub</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${styleVersion}" id="appStylesheet">
  <link rel="icon" href="${pageContext.request.contextPath}/img/logo-mark.svg" type="image/svg+xml">
  <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/img/logo-mark.svg">
</head>
<body>
<div class="auth-wrap">
  <div class="auth-mesh" aria-hidden="true"><span></span><span></span><span></span></div>

  <div class="auth-card">
    <div class="auth-logo">
      <img src="${pageContext.request.contextPath}/img/logo.svg" alt="" width="56" height="56">
    </div>
    <h1>Mangaud CollegeHub</h1>
    <p class="sub">Sign in to your account</p>

    <% if (!error.isEmpty()) { %>
      <div class="alert alert-error" role="alert"><%= error %></div>
    <% } %>

    <!-- ================= manual sign-in ================= -->
    <form method="post" action="${pageContext.request.contextPath}/login" id="loginForm" novalidate>
      <input type="hidden" name="csrf" value="<%= csrf %>"/>
      <div class="field" style="margin-bottom:14px">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" required autofocus
               autocomplete="username" placeholder="e.g. admin" spellcheck="false">
      </div>
      <div class="field" style="margin-bottom:8px">
        <label for="password">Password</label>
        <div style="position:relative">
          <input type="password" id="password" name="password" required
                 autocomplete="current-password" placeholder="••••••••" style="padding-right:44px">
          <button type="button" id="pwToggle" class="pw-toggle"
                  aria-label="Show password" aria-pressed="false">👁</button>
        </div>
        <div id="pwHint" class="field-hint" aria-live="polite"></div>
      </div>
      <button type="submit" class="btn btn-primary" style="width:100%;margin-top:10px">
        <span class="lbl-txt">Sign In</span>
      </button>
    </form>

    <% if (demo) { %>
    <!-- ================= one-tap demo sign-in ================= -->
    <div class="demo-block">
      <div class="divider"><span>or sign in instantly</span></div>
      <% for (String group : DemoLogin.groups()) { %>
        <div class="demo-group">
          <div class="demo-group-label"><%= group %></div>
          <div class="demo-grid">
            <% for (DemoLogin.Account a : DemoLogin.accountsIn(group)) { %>
            <button type="button" class="demo-tile"
                    data-u="<%= a.username %>" data-p="<%= a.password %>">
              <span class="demo-ico" aria-hidden="true"><%= a.icon %></span>
              <span class="demo-body">
                <span class="demo-label"><%= a.label %></span>
                <code class="demo-id"><%= a.username %></code>
              </span>
              <span class="demo-go" aria-hidden="true">→</span>
            </button>
            <% } %>
          </div>
        </div>
      <% } %>
      <p class="demo-note">
        Demo accounts seeded by <code>database/seed_demo_data.sql</code>.
        Each one lands on a different role dashboard.
      </p>
    </div>
    <% } %>

    <p class="auth-foot">
      <a href="${pageContext.request.contextPath}/health">System status</a>
    </p>
  </div>
</div>

<script src="${pageContext.request.contextPath}/js/app.js"></script>
<script>
(function () {
  var form  = document.getElementById('loginForm');
  var uEl   = document.getElementById('username');
  var pEl   = document.getElementById('password');
  var hint  = document.getElementById('pwHint');
  var toggle = document.getElementById('pwToggle');

  // show / hide password
  toggle.addEventListener('click', function () {
    var showing = pEl.type === 'text';
    pEl.type = showing ? 'password' : 'text';
    toggle.setAttribute('aria-pressed', showing ? 'false' : 'true');
    toggle.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
    pEl.focus();
  });

  // client-side required-field guard
  form.addEventListener('submit', function (e) {
    if (!uEl.value.trim()) { e.preventDefault(); uEl.focus(); hint.textContent = 'Username is required.'; return; }
    if (!pEl.value)         { e.preventDefault(); pEl.focus(); hint.textContent = 'Password is required.'; return; }
    hint.textContent = '';
    // The submit button is disabled briefly so a double click cannot post twice.
    form.querySelector('button[type=submit]').disabled = true;
  });

  // one-tap demo sign-in
  document.querySelectorAll('.demo-tile').forEach(function (tile) {
    tile.addEventListener('click', function () {
      uEl.value = tile.dataset.u;
      pEl.value = tile.dataset.p;
      pEl.type = 'text';
      tile.classList.add('is-busy');
      form.submit();          // submit() bypasses the submit handler: no double-post guard
    });
  });

  // Clear the hint as soon as the user starts typing again.
  [uEl, pEl].forEach(function (el) {
    el.addEventListener('input', function () { hint.textContent = ''; });
  });
})();
</script>
</body>
</html>
