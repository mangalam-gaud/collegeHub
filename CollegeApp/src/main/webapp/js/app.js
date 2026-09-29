/* ============================================================
 * CollegeHub — reactive interaction layer
 * Vanilla JS, zero dependencies. Loaded once per page via
 * layout/top.jsp and login.jsp.
 *   - persisted dark/light theme ([data-theme] + localStorage)
 *   - top loading bar on navigation / form submit
 *   - toast notifications for redirect feedback (?saved=1 etc.)
 *   - live table filtering, row counting, column sorting
 *   - numeric "count-up" animation for .stat .num
 *   - synthesized progress bars inside data-pct cells
 *   - skeleton shimmer on initial paint, staggered reveal
 *   - mobile drawer nav, focus-visible ripple on buttons
 * ============================================================ */
(function () {
  'use strict';
  var KEY = 'collegehub.theme';

  /* ---------- theme ---------- */
  function applyTheme(t) {
    document.documentElement.setAttribute('data-theme', t);
    try { localStorage.setItem(KEY, t); } catch (e) {}
    var ico = document.querySelector('[data-theme-toggle] use');
    if (ico) ico.setAttribute('href', t === 'dark' ? '#i-sun' : '#i-moon');
  }
  function storedTheme() {
    try {
      var v = localStorage.getItem(KEY);
      return v === 'dark' || v === 'light' ? v : null;
    } catch (e) { return null; }
  }
  applyTheme(storedTheme() ||
    (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'));

  document.addEventListener('click', function (e) {
    var t = e.target.closest('[data-theme-toggle]');
    if (t) {
      applyTheme(document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
      toast('Switched to ' + document.documentElement.getAttribute('data-theme') + ' theme', 'success');
    }
  });

  /* ---------- SVG sprite (inline, CSP-safe) ---------- */
  (function ensureIcons() {
    if (document.getElementById('ch-icons')) return;
    var s = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    s.setAttribute('id', 'ch-icons');
    s.setAttribute('style', 'position:absolute;width:0;height:0;overflow:hidden');
    s.innerHTML =
      '<symbol id="i-moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z"/></symbol>' +
      '<symbol id="i-sun" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M19.1 4.9l-1.4 1.4M6.3 17.7l-1.4 1.4"/></symbol>' +
      '<symbol id="i-menu" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 6h18M3 12h18M3 18h18"/></symbol>';
    document.body.appendChild(s);
  })();

  function icon(id) { return '<svg aria-hidden="true"><use href="#' + id + '"/></svg>'; }

  /* ---------- toast ---------- */
  function stack() {
    var st = document.querySelector('.toast-stack');
    if (!st) { st = document.createElement('div'); st.className = 'toast-stack'; document.body.appendChild(st); }
    return st;
  }
  function toast(msg, kind) {
    var st = stack();
    var el = document.createElement('div');
    el.className = 'toast ' + (kind === 'error' ? 'error' : 'success');
    el.setAttribute('role', 'status');
    var g = kind === 'error' ? '!' : '✓';
    el.innerHTML = '<span class="t-ico">' + g + '</span><span class="t-msg"></span>' +
      '<button class="t-x" aria-label="Dismiss">×</button>';
    el.querySelector('.t-msg').textContent = String(msg || '');
    st.appendChild(el);
    var kill = function () { el.classList.add('out'); setTimeout(function () { el.remove(); }, 320); };
    el.querySelector('.t-x').addEventListener('click', kill);
    setTimeout(kill, 4200);
    while (st.children.length > 4) st.firstChild.remove();
  }
  window.collegehub = window.collegehub || {};
  window.collegehub.toast = toast;

  /* ---------- loading bar ---------- */
  var bar = document.createElement('div');
  bar.className = 'progress-bar';
  bar.setAttribute('aria-hidden', 'true');
  document.body.appendChild(bar);
  function busy() { bar.style.display = 'block'; }
  function idle() { bar.style.display = 'none'; }
  idle();

  window.addEventListener('beforeunload', function () { busy(); });
  window.addEventListener('load', function () { idle(); });

  document.addEventListener('submit', function (e) {
    if (!e.target || e.target.tagName !== 'FORM') return;
    busy();
    var btn = e.target.querySelector('button[type="submit"], button:not([type])');
    if (btn && !btn.classList.contains('btn-danger')) {
      btn.classList.add('is-busy');
      if (!btn.querySelector('.spin')) {
        var s = document.createElement('span');
        s.className = 'spin';
        s.setAttribute('aria-hidden', 'true');
        btn.appendChild(s);
      }
      var txt = btn.querySelector('.lbl-txt');
      if (!txt) {
        txt = document.createElement('span');
        txt.className = 'lbl-txt';
        while (btn.firstChild && btn.firstChild.nodeType === 3) txt.appendChild(btn.firstChild);
        btn.prepend(txt);
      }
    }
  });

  /* ---------- redirect feedback → toast ---------- */
  (function flashParams() {
    var messages = {
      saved: 'Saved successfully.',
      pwchanged: 'Password changed successfully.',
      pwerror: 'Password must be at least 6 characters.',
      deleted: 'Record deleted.',
      created: 'Created successfully.',
      updated: 'Updated successfully.'
    };
    var qs = new URLSearchParams(location.search);
    var shown = false;
    qs.forEach(function (v, k) {
      if (messages[k] && v === '1') { toast(messages[k], 'success'); shown = true; }
      if (k === 'pwerror' && v === '1') { toast(messages.pwerror, 'error'); shown = true; }
    });
    if (!shown) {
      var err = document.querySelector('.alert-error');
      if (err) toast(err.textContent.trim(), 'error');
    }
  })();

  /* ---------- buttons: ripple ---------- */
  document.addEventListener('click', function (e) {
    var b = e.target.closest('.btn');
    if (!b) return;
    if (b.classList.contains('btn-danger')) return; // confirm() flow
    var r = document.createElement('span');
    r.className = 'ripple';
    var rc = b.getBoundingClientRect();
    var d = Math.max(rc.width, rc.height);
    r.style.width = r.style.height = d + 'px';
    r.style.left = (e.clientX - rc.left - d / 2) + 'px';
    r.style.top = (e.clientY - rc.top - d / 2) + 'px';
    b.appendChild(r);
    setTimeout(function () { r.remove(); }, 600);
  });

  /* ---------- mobile drawer ---------- */
  document.addEventListener('click', function (e) {
    if (e.target.closest('.hamburger')) {
      document.body.classList.toggle('nav-open');
      return;
    }
    if (document.body.classList.contains('nav-open') &&
        !e.target.closest('.sidebar')) document.body.classList.remove('nav-open');
  });

  /* ---------- skeleton → reveal ---------- */
  function decorate() {
    document.querySelectorAll('.stat, .card, .table-wrap').forEach(function (el) {
      el.classList.add('reveal');
    });
    /* count-up */
    document.querySelectorAll('.stat .num').forEach(function (n) {
      var raw = String(n.textContent).replace(/[^\d.\-]/g, '');
      var num = parseFloat(raw);
      if (isNaN(num) || raw === '') return;
      var suffix = String(n.textContent).replace(raw, '');
      var t0 = null, dur = 750;
      function step(ts) {
        if (!t0) t0 = ts;
        var p = Math.min(1, (ts - t0) / dur);
        var e = 1 - Math.pow(1 - p, 3);
        n.textContent = (Math.round(num * e * 10) / 10) + suffix;
        if (p < 1) requestAnimationFrame(step);
      }
      n.textContent = '0' + suffix;
      requestAnimationFrame(step);
    });
    /* progress bars from data-pct */
    document.querySelectorAll('[data-pct]').forEach(function (cell) {
      if (cell.querySelector('.bar')) return;
      var pct = parseFloat(cell.getAttribute('data-pct'));
      if (isNaN(pct)) return;
      var wrap = document.createElement('div');
      wrap.className = 'bar ' + (pct >= 75 ? 'good' : pct > 0 ? 'low' : '');
      wrap.innerHTML = '<i></i>';
      cell.appendChild(wrap);
      requestAnimationFrame(function () { wrap.firstElementChild.style.width = Math.min(100, pct) + '%'; });
    });
    /* table row counts */
    document.querySelectorAll('table').forEach(function (t) {
      var c = t.querySelector('tfoot .rowcount, .rowcount');
      if (c) return;
      var n = t.querySelectorAll('tbody tr').length;
      t.querySelectorAll('th.countable, thead th:first-child').forEach(function () {});
    });
    document.querySelectorAll('[data-count]').forEach(function (el) {
      var t = el.getAttribute('data-count-target');
      if (!t) return;
      var n = document.querySelectorAll(t).length;
      el.textContent = n;
    });
    /* sort headers */
    document.querySelectorAll('th[data-sort]').forEach(function (th) {
      th.setAttribute('title', 'Click to sort');
    });
  }

  /* ---------- table sorting (client side) ---------- */
  document.addEventListener('click', function (e) {
    var th = e.target.closest('th[data-sort]');
    if (!th) return;
    var table = th.closest('table');
    if (!table) return;
    var rows = Array.prototype.slice.call(table.querySelectorAll('tbody tr'));
    if (!rows.length) return;
    var idx = Array.prototype.indexOf.call(th.parentNode.children, th);
    var dir = th.getAttribute('data-dir') === 'asc' ? -1 : 1;
    th.setAttribute('data-dir', dir === 1 ? 'asc' : 'desc');
    table.querySelectorAll('th[data-sort]').forEach(function (o) {
      if (o !== th) o.removeAttribute('data-dir');
    });
    rows.sort(function (a, b) {
      var av = (a.children[idx] || {}).textContent || '';
      var bv = (b.children[idx] || {}).textContent || '';
      var an = parseFloat(av.replace(/[^\d.\-]/g, '')), bn = parseFloat(bv.replace(/[^\d.\-]/g, ''));
      var r;
      if (!isNaN(an) && !isNaN(bn) && av.match(/\d/)) r = an - bn;
      else r = av.localeCompare(bv, undefined, { numeric: true, sensitivity: 'base' });
      return r * dir;
    });
    var tb = table.querySelector('tbody');
    rows.forEach(function (r) { tb.appendChild(r); });
    th.textContent = th.textContent.replace(/ [▲▼]$/, '') + (dir === 1 ? ' ▲' : ' ▼');
  });

  /* ---------- live filtering for admin user search ---------- */
  document.addEventListener('input', function (e) {
    var q = e.target.closest('[data-filter]');
    if (!q) return;
    var sel = q.getAttribute('data-filter');
    var tables = document.querySelectorAll(sel);
    var v = q.value.toLowerCase();
    tables.forEach(function (table) {
      var hit = 0;
      table.querySelectorAll('tbody tr').forEach(function (tr) {
        var m = tr.textContent.toLowerCase().indexOf(v) > -1;
        tr.classList.toggle('dim', !m);
        if (m) hit++;
      });
      table.querySelectorAll('tbody tr').forEach(function (tr) {
        tr.classList.toggle('hit', v && tr.textContent.toLowerCase().indexOf(v) > -1);
      });
      var badge = document.querySelector('[data-filter-count="' + sel + '"]');
      if (badge) badge.textContent = hit;
    });
  });

  /* ---------- clock ---------- */
  (function clock() {
    var el = document.querySelector('.clock');
    if (!el) return;
    function tick() {
      var d = new Date();
      el.textContent = d.toLocaleDateString([], { month: 'short', day: 'numeric' }) +
        ' · ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    }
    tick(); setInterval(tick, 1000);
  })();

  /* ---------- keyboard: / focuses search, esc closes drawer ---------- */
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') document.body.classList.remove('nav-open');
    if (e.key === '/' && !/^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName)) {
      var f = document.querySelector('[data-filter]');
      if (f) { e.preventDefault(); f.focus(); }
    }
  });

  /* ---------- initial paint ---------- */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', decorate);
  } else {
    decorate();
  }
})();
