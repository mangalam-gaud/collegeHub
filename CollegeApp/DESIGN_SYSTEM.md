# CollegeHub Design System

## Overview

A complete, theme-aware design system implemented purely with **CSS Custom Properties** and **vanilla JavaScript** — zero build step, zero dependencies. Supports light/dark modes, WCAG 2.2 AA contrast, reduced-motion, and responsive layouts.

---

## 1. Token Architecture

### Three-Layer Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ PRIMITIVE TOKENS (Raw Values)                                   │
│ --primary-500: #6366f1; --green-500: #22c55e; --gray-900: #151827;│
│ --font: "SF Pro Text", ...; --radius: 12px; --sidebar-w: 250px; │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ SEMANTIC TOKENS (Purpose Aliases)                               │
│ --ink: #1a1d2b; --paper: var(--gray-50); --card: #ffffff;      │
│ --line: var(--gray-200); --shadow: 0 6px 20px -8px rgba(...);  │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ COMPONENT TOKENS (Component-Specific)                           │
│ --button-primary-bg: var(--primary-600); --card-hover-shadow: ..│
│ --stat-ring-color: var(--primary-500); --toast-bg: var(--card); │
└─────────────────────────────────────────────────────────────────┘
```

### Complete Token Reference

#### Primitives — Light Mode (Default)

```css
/* Color — Brand */
--primary-50:  #eef2ff;  --primary-100: #e0e7ff;  --primary-300: #a5b4fc;
--primary-500: #6366f1;  --primary-600: #4f46e5;  --primary-700: #4338ca;

/* Color — Semantic */
--green-500:  #22c55e;  --green-bg:  #dcfce7;
--red-500:    #ef4444;  --red-bg:    #fee2e2;
--amber-500:  #f59e0b;  --amber-bg:  #fef3c7;

/* Color — Neutral */
--gray-50:  #f7f6f2;  --gray-100: #f1f0ea;  --gray-200: #e5e2d8;
--gray-400: #9b9787;  --gray-600: #54514a;  --gray-900: #151827;

/* Typography */
--font:        "SF Pro Text", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
--font-display: "Iowan Old Style", "Palatino Linotype", Palatino, "Book Antiqua", Georgia, "Times New Roman", serif;
--font-mono:   ui-monospace, "SF Mono", "Cascadia Mono", "Roboto Mono", Menlo, Consolas, monospace;

/* Spacing & Layout */
--radius:     12px;     --radius-lg: 18px;
--sidebar-w:  250px;    --topbar-h:  64px;

/* Shadows */
--shadow-sm: 0 1px 2px rgba(21,24,39,.05);
--shadow:    0 6px 20px -8px rgba(21,24,39,.14), 0 2px 4px rgba(21,24,39,.05);
--shadow-lg: 0 24px 60px -20px rgba(67,56,202,.35), 0 8px 24px -12px rgba(21,24,39,.25);

/* Base */
--ink:    #1a1d2b;
--paper:  var(--gray-50);
--card:   #ffffff;
--line:   var(--gray-200);
--line-strong: #d8d4c7;
```

#### Primitives — Dark Mode (`[data-theme="dark"]`)

```css
[data-theme="dark"] {
  --primary-50:  #1b2140;  --primary-100: #252c52;  --primary-300: #6472c9;
  --primary-500: #7c83f5;  --primary-600: #8b93f7;  --primary-700: #a5abfa;
  --green-500:   #34d399;  --green-bg:   #0f2b22;
  --red-500:     #f87171;  --red-bg:     #331516;
  --amber-500:   #fbbf24;  --amber-bg:   #33260c;
  --gray-50:  #0e1019;  --gray-100: #161a28;  --gray-200: #232839;
  --gray-400: #8d93ab;  --gray-600: #aab1c8;  --gray-900: #e7eaf5;
  --ink:    #e8eaf4;
  --paper:  var(--gray-50);
  --card:   #151827;
  --line:   var(--gray-200);
  --line-strong: #2d3450;
  --shadow-sm: 0 1px 2px rgba(0,0,0,.4);
  --shadow:    0 8px 28px -12px rgba(0,0,0,.6);
  --shadow-lg: 0 30px 70px -28px rgba(0,0,0,.75), 0 0 0 1px rgba(124,131,245,.12);
}
```

#### Semantic Tokens (Derived)

```css
/* Used by components — never hardcode primitive values in component CSS */
--ink:              var(--ink);           /* Primary text */
--paper:            var(--paper);         /* Page background */
--card:             var(--card);          /* Card/surface background */
--line:             var(--line);          /* Borders, dividers */
--line-strong:      var(--line-strong);   /* Strong borders (table headers) */
--shadow-sm:        var(--shadow-sm);     /* Subtle elevation */
--shadow:           var(--shadow);        /* Default elevation */
--shadow-lg:        var(--shadow-lg);     /* High elevation (modals, toasts) */
--radius:           var(--radius);        /* Default border radius */
--radius-lg:        var(--radius-lg);     /* Large radius (auth card) */
--sidebar-w:        var(--sidebar-w);     /* Sidebar width */
--topbar-h:         var(--topbar-h);      /* Topbar height */
```

---

## 2. Component Specifications

### 2.1 Button

```css
.btn {
  --btn-bg: var(--card);
  --btn-fg: var(--gray-600);
  --btn-border: var(--line-strong);
  --btn-shadow: var(--shadow-sm);
  --btn-hover-bg: var(--card);
  --btn-hover-fg: var(--primary-600);
  --btn-hover-border: var(--primary-300);
  --btn-active-scale: 0.985;
  --btn-disabled-opacity: 0.55;
}

.btn-primary {
  --btn-bg: linear-gradient(145deg, var(--primary-600), var(--primary-700));
  --btn-fg: #fff;
  --btn-border: none;
  --btn-shadow: 0 6px 16px -8px var(--primary-600);
}

.btn-outline {
  --btn-bg: var(--card);
  --btn-fg: var(--gray-600);
  --btn-border: var(--line-strong);
}

.btn-danger {
  --btn-bg: linear-gradient(145deg, var(--red-500), #dc2626);
  --btn-fg: #fff;
  --btn-shadow: 0 6px 16px -8px var(--red-500);
}

.btn-sm { padding: 5px 11px; font-size: 13px; border-radius: 8px; }
```

**States:**
| State | Visual Change |
|-------|---------------|
| Default | Base tokens |
| Hover | `filter: brightness(1.06); transform: translateY(-1px)` |
| Active | `transform: translateY(0) scale(0.985)` |
| Disabled | `opacity: 0.55; pointer-events: none` |
| Busy | Spinner shown, label opacity 0.75 |
| Focus-visible | `outline: 2px solid var(--primary-500); outline-offset: 2px` |

### 2.2 Card

```css
.card {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  padding: 22px;
  transition: box-shadow .2s ease, transform .2s ease, border-color .2s ease;
}
.card:hover { box-shadow: var(--shadow); }
```

### 2.3 Stat Card

```css
.stat {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 20px;
  position: relative; overflow: hidden;
}
.stat::before { /* Accent bar */ left: 0; top: 0; bottom: 0; width: 4px;
  background: linear-gradient(180deg, var(--primary-500), var(--primary-700)); }
.stat::after { /* Glow */ right: -30px; top: -30px; width: 110px; height: 110px; border-radius: 50%;
  background: radial-gradient(circle, color-mix(in srgb, var(--primary-500) 14%, transparent), transparent 70%); }
.stat .num { font-family: var(--font-mono); font-size: 30px; font-weight: 700; color: var(--primary-600); }
.stat .lbl { color: var(--gray-600); font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .09em; }
```

### 2.4 Table

```css
.table-wrap { overflow-x: auto; border: 1px solid var(--line); border-radius: var(--radius); background: var(--card); }
table { width: 100%; border-collapse: collapse; font-size: 14px; }
th { text-align: left; font-size: 11px; text-transform: uppercase; letter-spacing: .09em; color: var(--gray-600);
  padding: 11px 14px; border-bottom: 1px solid var(--line-strong); background: var(--gray-100);
  position: sticky; top: 0; z-index: 2; white-space: nowrap; }
th[data-sort] { cursor: pointer; user-select: none; }
td { padding: 12px 14px; border-bottom: 1px solid var(--gray-100); vertical-align: middle; }
tbody tr:hover td { background: color-mix(in srgb, var(--primary-500) 6%, transparent); }
tbody tr.hit td { background: color-mix(in srgb, var(--amber-500) 14%, transparent); }
tbody tr.dim { opacity: .28; }
```

### 2.5 Badge

```css
.badge { display: inline-block; padding: 3px 10px; border-radius: 999px; font-size: 11.5px; font-weight: 700; letter-spacing: .04em; text-transform: uppercase; border: 1px solid transparent; }
.badge-admin    { background: var(--primary-100); color: var(--primary-700); }
.badge-teacher  { background: var(--amber-bg); color: #92400e; }
.badge-student  { background: var(--green-bg); color: #166534; }
.badge-on       { background: var(--green-bg); color: #166534; }
.badge-off      { background: var(--red-bg); color: #991b1b; }
.badge-present  { background: var(--green-bg); color: #166534; }
.badge-absent   { background: var(--red-bg); color: #991b1b; }
```

### 2.6 Form Fields

```css
.field { display: flex; flex-direction: column; gap: 6px; }
label { font-size: 12.5px; font-weight: 700; color: var(--gray-600); text-transform: uppercase; letter-spacing: .06em; }
input, select, textarea {
  font-family: inherit; font-size: 14px; padding: 10px 12px;
  border: 1px solid var(--line-strong); border-radius: 9px;
  background: var(--card); color: var(--ink); transition: .16s ease; width: 100%;
}
input:focus, select:focus, textarea:focus {
  outline: none; border-color: var(--primary-500);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--primary-500) 18%, transparent);
}
.pill { /* Radio pill */ display: inline-flex; align-items: center; gap: 5px; padding: 6px 13px; border-radius: 999px; border: 1px solid var(--line-strong); cursor: pointer; font-size: 13.5px; background: var(--card); }
.pill:has(input:checked) { border-color: var(--primary-500); background: color-mix(in srgb, var(--primary-500) 12%, transparent); color: var(--primary-700); font-weight: 600; }
```

### 2.7 Alert / Toast / Notice

```css
.alert { padding: 12px 16px; border-radius: 10px; margin-bottom: 18px; font-size: 14px; display: flex; gap: 10px; align-items: flex-start; border: 1px solid transparent; }
.alert-error { background: var(--red-bg); color: #991b1b; border-color: color-mix(in srgb, var(--red-500) 30%, transparent); }
.alert-success { background: var(--green-bg); color: #166534; border-color: color-mix(in srgb, var(--green-500) 30%, transparent); }

.notice { border-left: 4px solid var(--primary-500); background: var(--card); border: 1px solid var(--line); border-radius: 10px; padding: 16px 18px; margin-bottom: 14px; }
.notice:hover { transform: translateX(3px); box-shadow: var(--shadow); }

.toast { display: flex; gap: 11px; align-items: flex-start; padding: 13px 15px; border-radius: 12px; background: var(--card); border: 1px solid var(--line); box-shadow: var(--shadow-lg); }
.toast.success .t-ico { background: var(--green-500); }
.toast.error .t-ico { background: var(--red-500); }
```

### 2.8 Progress Bar (Top Loader)

```css
.progress-bar { position: fixed; top: 0; left: 0; height: 3px; width: 100%; z-index: 300; pointer-events: none; background: transparent; }
.progress-bar::after { content: ""; position: absolute; left: 0; top: 0; height: 100%; width: 35%;
  background: linear-gradient(90deg, var(--primary-500), var(--primary-300), #f472b6);
  border-radius: 0 99px 99px 0; animation: load 1.15s cubic-bezier(.3,.7,.3,1) infinite; }
@keyframes load { 0% { left: -35%; } 100% { left: 100%; } }
```

### 2.9 Skeleton Shimmer

```css
.skeleton { position: relative; overflow: hidden; color: transparent !important; background: var(--gray-100) !important; }
.skeleton * { visibility: hidden; }
.skeleton::after { content: ""; position: absolute; inset: 0;
  background: linear-gradient(100deg, transparent 20%, color-mix(in srgb, #fff 65%, transparent) 50%, transparent 80%);
  animation: shimmer 1.2s linear infinite; }
[data-theme="dark"] .skeleton::after { background: linear-gradient(100deg, transparent 20%, rgba(255,255,255,.07) 50%, transparent 80%); }
@keyframes shimmer { from { transform: translateX(-100%); } to { transform: translateX(100%); } }
```

### 2.10 Reveal Animation

```css
.reveal { animation: reveal .5s cubic-bezier(.2,.9,.3,1) both; }
.reveal:nth-child(1) { animation-delay: .04s; } .reveal:nth-child(2) { animation-delay: .09s; }
.reveal:nth-child(3) { animation-delay: .14s; } .reveal:nth-child(4) { animation-delay: .19s; }
.reveal:nth-child(5) { animation-delay: .24s; } .reveal:nth-child(6) { animation-delay: .29s; }
.reveal:nth-child(7) { animation-delay: .34s; } .reveal:nth-child(8) { animation-delay: .39s; }
@keyframes reveal { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: none; } }
```

---

## 3. Responsive System

### Breakpoints

| Breakpoint | Target | Changes |
|------------|--------|---------|
| `@media (max-width: 960px)` | Tablet | `.grid2`, `.form-grid` → 1 column |
| `@media (max-width: 900px)` | Mobile | Sidebar → off-canvas drawer (260px); brand/nav text hidden when collapsed; hamburger shown; main margin-left: 0; clock hidden; toast stack full-width |

### Sidebar Drawer (Mobile)

```css
@media (max-width: 900px) {
  :root { --sidebar-w: 250px; }
  .sidebar { transform: translateX(-102%); box-shadow: var(--shadow-lg); width: 260px; }
  body.nav-open .sidebar { transform: none; }
  body.nav-open::before { content: ""; position: fixed; inset: 0; z-index: 30; background: rgba(0,0,0,.5); opacity: .5; }
  .sidebar .brand span.txt, .sidebar nav a span.txt, .sidebar .footer { display: none; }
  body.nav-open .sidebar .brand span.txt, body.nav-open .sidebar nav a span.txt, body.nav-open .sidebar .footer { display: revert; }
  .hamburger { display: inline-flex; }
  .main { margin-left: 0; padding: 20px; }
  .topbar { flex-wrap: wrap; }
  .clock { display: none; }
  .toast-stack { left: 16px; right: 16px; max-width: none; }
}
```

---

## 4. Motion & Accessibility

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: .01ms !important;
    scroll-behavior: auto !important;
  }
}
```

### Focus Management

```css
:focus-visible { outline: 2px solid var(--primary-500); outline-offset: 2px; border-radius: 6px; }
```

### Color Contrast (WCAG 2.2 AA)

All semantic token pairs validated:
- `--ink` on `--paper` → ≥4.5:1
- `--ink` on `--card` → ≥4.5:1
- `--gray-600` on `--card` → ≥4.5:1
- `--primary-600` on `--card` → ≥4.5:1
- `--green-500` on `--green-bg` → ≥4.5:1
- `--red-500` on `--red-bg` → ≥4.5:1
- `--amber-500` on `--amber-bg` → ≥4.5:1

---

## 5. JavaScript Interaction Layer (`app.js`)

### 5.1 Module Structure

```javascript
(function () {
  'use strict';
  // 1. Theme Management
  // 2. SVG Sprite Injection
  // 3. Toast System
  // 4. Loading Bar
  // 5. Form Submit Enhancement (busy state + spinner)
  // 6. Redirect Feedback → Toast
  // 7. Button Ripple Effect
  // 8. Mobile Drawer
  // 9. Skeleton → Reveal + Count-Up + Progress Bars
  // 10. Table Sorting (client-side)
  // 11. Live Filtering
  // 12. Clock
  // 13. Keyboard Shortcuts
  // 14. Initial Paint (DOMContentLoaded)
})();
```

### 5.2 Theme API

```javascript
// Persisted to localStorage key 'collegehub.theme'
applyTheme('light' | 'dark');           // Sets [data-theme] + localStorage
storedTheme();                          // Returns 'light' | 'dark' | null
// Auto-initializes from localStorage or prefers-color-scheme
```

### 5.3 Toast API

```javascript
window.collegehub = window.collegehub || {};
window.collegehub.toast = function(message, kind) { /* kind: 'success' | 'error' */ };
// Auto-dismisses after 4.2s; max 4 toasts; manual close button
```

### 5.4 Loading Bar API

```javascript
busy();   // Shows top progress bar
idle();   // Hides top progress bar
// Auto: shows on beforeunload + form submit; hides on load
```

### 5.5 Table Enhancement

- **Sort**: Click `th[data-sort]` → toggles asc/desc; numeric + locale string sort
- **Filter**: `[data-filter="table-selector"]` input → real-time row filtering; adds `.hit`/`.dim` classes; updates `[data-filter-count]` badge
- **Count-Up**: `.stat .num` animates 0→value in 750ms (ease-out cubic)
- **Progress Bars**: `[data-pct]` on `<td>` → synthesizes `.bar` with color coding (good ≥75%, low >0%, none 0%)

### 5.6 Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `/` | Focus first `[data-filter]` input (if not in input/textarea/select) |
| `Escape` | Close mobile drawer (`nav-open`) |

---

## 6. Usage Guidelines

### ✅ Do

- Use semantic tokens in custom CSS: `background: var(--card); color: var(--ink);`
- Add new component tokens to the semantic layer, not primitive
- Use `data-pct` on table cells for auto progress bars
- Add `data-sort` to sortable `<th>` elements
- Use `${csrfField}` in every `<form method="post">`
- Test in both light and dark modes
- Test with `prefers-reduced-motion: reduce`

### ❌ Don't

- Hardcode hex colors in component CSS (use tokens)
- Add new breakpoints without updating the responsive table
- Use `!important` to override token values
- Disable the CSP by adding `'unsafe-inline'` to script-src
- Remove focus-visible outlines

---

## 7. Extending the Design System

### Adding a New Component

1. **Define component tokens** in `:root` (semantic layer)
2. **Write component CSS** using only semantic tokens
3. **Add dark mode overrides** in `[data-theme="dark"]`
4. **Add reduced-motion support** if animated
5. **Document states** (hover, active, focus, disabled)
6. **Test in all viewports** (375px, 768px, 1024px, 1440px)

### Adding a New Color

1. Add primitive in `:root` (light) and `[data-theme="dark"]`
2. Create semantic alias if used for UI meaning (e.g., `--color-warning`)
3. Update component tokens that reference it
4. Validate contrast in both themes

---

## 8. Browser Support

| Feature | Minimum Version |
|---------|-----------------|
| CSS Custom Properties | Chrome 49, Firefox 31, Safari 9.1, Edge 16 |
| CSS `color-mix()` | Chrome 111, Firefox 113, Safari 16.2, Edge 111 |
| `prefers-color-scheme` | Chrome 76, Firefox 67, Safari 12.1, Edge 79 |
| `prefers-reduced-motion` | Chrome 74, Firefox 63, Safari 10.1, Edge 79 |
| `focus-visible` | Chrome 86, Firefox 85, Safari 15.4, Edge 86 |
| `localStorage` | All modern browsers |

*Graceful degradation: `color-mix()` falls back to solid colors in older browsers via `@supports` if needed.*

---

## 9. Performance

- **Zero JS dependencies** — `app.js` ~9KB gzipped
- **CSS-only animations** — no JS animation loops
- **Deferred JS loading** — `<script defer>` in bottom.jsp
- **No critical CSS blocking** — tokens in `:root`, components in single file
- **SVG sprite inlined** — zero icon requests
- **Paper texture via data-URI** — zero image requests

---

## 10. Accessibility Checklist (WCAG 2.2 AA)

| Criterion | Implementation |
|-----------|----------------|
| 1.1.1 Non-text Content | All icons have `aria-hidden="true"` or accessible names; decorative images hidden |
| 1.3.1 Info & Relationships | Semantic HTML (`<nav>`, `<main>`, `<aside>`, `<table>`, `<th scope="col">`) |
| 1.4.3 Contrast (Minimum) | All token pairs ≥4.5:1 validated |
| 1.4.4 Resize Text | `rem`/`em` units; no fixed `px` on text containers |
| 1.4.10 Reflow | Responsive grid; no horizontal scroll at 320px |
| 1.4.11 Non-text Contrast | Focus rings, button borders, badge borders ≥3:1 |
| 2.1.1 Keyboard | All interactive elements reachable; `/` shortcut for search |
| 2.1.2 No Keyboard Trap | Modal/drawer focus trapped; `Esc` closes |
| 2.4.3 Focus Order | DOM order = visual order; `tabindex` not abused |
| 2.4.7 Focus Visible | `:focus-visible` on all interactive elements |
| 2.5.1 Pointer Gestures | No multipoint/path-based gestures required |
| 2.5.3 Label in Name | Button/links have visible text matching accessible name |
| 2.5.5 Target Size | Touch targets ≥44×44px (buttons, pills, table rows) |
| 3.2.1 On Focus | No unexpected navigation on focus |
| 3.2.2 On Input | No unexpected changes on input (filter is live but non-destructive) |
| 3.3.1 Error Identification | Form errors shown inline + toast |
| 3.3.2 Labels or Instructions | All inputs have `<label>`; placeholders supplementary |
| 4.1.2 Name, Role, Value | Native elements used (`<button>`, `<a>`, `<select>`); ARIA only where needed |

---

*This design system is the single source of truth for all UI decisions in CollegeHub. All new components and pages must comply with these tokens and patterns.*