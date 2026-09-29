package com.college.util;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/** Simple in-memory login rate limiter: max 5 failed attempts per username per 10 minutes. */
public class LoginRateLimiter {
    private static final int MAX_ATTEMPTS = 5;
    private static final long WINDOW_MS = 10 * 60 * 1000L;

    private static final Map<String, Attempt> ATTEMPTS = new ConcurrentHashMap<>();

    private static class Attempt {
        int count;
        long windowStart;
    }

    public static boolean isBlocked(String username) {
        Attempt a = ATTEMPTS.get(username);
        if (a == null) return false;
        if (System.currentTimeMillis() - a.windowStart > WINDOW_MS) {
            ATTEMPTS.remove(username);
            return false;
        }
        return a.count >= MAX_ATTEMPTS;
    }

    public static void recordFailure(String username) {
        Attempt a = ATTEMPTS.computeIfAbsent(username, k -> new Attempt());
        synchronized (a) {
            if (System.currentTimeMillis() - a.windowStart > WINDOW_MS) {
                a.count = 0;
                a.windowStart = System.currentTimeMillis();
            }
            a.count++;
        }
    }

    public static void reset(String username) {
        ATTEMPTS.remove(username);
    }

    public static int remaining(String username) {
        Attempt a = ATTEMPTS.get(username);
        if (a == null) return MAX_ATTEMPTS;
        return Math.max(0, MAX_ATTEMPTS - a.count);
    }
}
