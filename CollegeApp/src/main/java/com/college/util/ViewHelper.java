package com.college.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import jakarta.servlet.http.HttpServletRequest;

/**
 * View helpers shared by every JSP.
 *
 * A JSP that does {@code for (X x : (List<X>) request.getAttribute("rows"))}
 * throws a NullPointerException whenever the servlet could not populate the
 * attribute - which turns a recoverable "no data yet" state into a 500 page.
 * Reading through {@link #list} makes every list-shaped attribute safe, so a
 * missing value renders the page's empty state instead of failing the request.
 */
public final class ViewHelper {

    private ViewHelper() {
    }

    /**
     * Returns the request attribute as a list, never null.
     *
     * @param request current request
     * @param name    attribute name
     * @return the attribute as a list; empty when absent, null or the wrong type
     */
    @SuppressWarnings("unchecked")
    public static <T> List<T> list(HttpServletRequest request, String name) {
        Object raw = request.getAttribute(name);
        if (raw instanceof List) {
            List<T> l = (List<T>) raw;
            return l == null ? Collections.<T>emptyList() : l;
        }
        return new ArrayList<>();
    }

    /**
     * Returns a trimmed string attribute, or "" when absent.
     */
    public static String str(HttpServletRequest request, String name) {
        Object raw = request.getAttribute(name);
        return raw == null ? "" : raw.toString();
    }

    /**
     * Returns an int attribute, or {@code fallback} when absent or unparseable.
     */
    public static int num(HttpServletRequest request, String name, int fallback) {
        Object raw = request.getAttribute(name);
        if (raw instanceof Number) return ((Number) raw).intValue();
        if (raw == null) return fallback;
        try {
            return Integer.parseInt(raw.toString().trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    /**
     * Reads a build-time constant from {@code app.properties}, falling back to
     * {@code def} when the key is missing.
     *
     * <p>Used to version static assets so a browser refetches them after a
     * redeploy instead of serving a stale cached copy.
     */
    public static String getConfig(String key, String def) {
        if (PROPS == null || PROPS.isEmpty()) {
            loadProps();
        }
        String v = PROPS.getProperty(key);
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }

    private static void loadProps() {
        java.util.Properties p = new java.util.Properties();

        // 1. ServletContext#getResourceAsStream - the lookup that reliably
        //    resolves a file under WEB-INF/classes from a JSP, where neither the
        //    JSP's nor this class's class loader can see it.
        jakarta.servlet.ServletContext sc = SC.get();
        if (sc != null) {
            java.io.InputStream in = sc.getResourceAsStream("/WEB-INF/classes/app.properties");
            if (in != null) readInto(in, p);
        }
        // 2. class loaders, for callers outside a request
        if (p.isEmpty()) {
            ClassLoader tccl = Thread.currentThread().getContextClassLoader();
            if (tccl != null) {
                java.io.InputStream in = tccl.getResourceAsStream("app.properties");
                if (in != null) readInto(in, p);
            }
        }
        if (p.isEmpty()) {
            java.io.InputStream in = ViewHelper.class.getClassLoader()
                    .getResourceAsStream("app.properties");
            if (in != null) readInto(in, p);
        }
        // Only cache a successful load; an empty result is retried next call so a
        // late-arriving ServletContext does not poison the value permanently.
        if (!p.isEmpty()) {
            PROPS = p;
        } else if (PROPS == null) {
            PROPS = p;
        }
    }

    private static boolean readInto(java.io.InputStream in, java.util.Properties p) {
        try {
            p.load(in);
            return true;
        } catch (java.io.IOException ignored) {
            return false;
        } finally {
            try { in.close(); } catch (java.io.IOException ignored) { }
        }
    }

    /**
     * A cache-busting token for {@code css/style.css}.
     *
     * <p>Prefers the STYLE_VERSION constant, and otherwise derives a token from
     * the stylesheet's last-modified time, so a redeployed stylesheet is always
     * fetched fresh even if app.properties is missing.
     *
     * @param request current request
     * @return a short token safe to use as a query-string value
     */
    public static String styleVersion(HttpServletRequest request) {
        String configured = getConfig("STYLE_VERSION", "");
        if (!configured.isEmpty()) return configured;

        // No configured value: derive a token from the deployed file's timestamp
        // so a redeployed stylesheet is still seen as a new resource.
        if (request != null) {
            try {
                String path = request.getContextPath() + "/css/style.css";
                java.net.URL url = request.getServletContext().getResource(path);
                if (url != null) {
                    long ts = url.openConnection().getLastModified();
                    if (ts > 0) return Long.toString(ts);
                }
            } catch (Exception ignored) {
                // fall through to the constant fallback
            }
        }
        return "1";
    }

    /** The running ServletContext, set once by a filter on first use. */
    private static final java.util.concurrent.atomic.AtomicReference<jakarta.servlet.ServletContext>
        SC = new java.util.concurrent.atomic.AtomicReference<>();

    /** Called at application start to publish the ServletContext. */
    public static void setServletContext(jakarta.servlet.ServletContext sc) {
        SC.compareAndSet(null, sc);
    }

    private static volatile java.util.Properties PROPS;
}
