package com.college.servlet;

import com.college.util.DBUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/health")
public class HealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        boolean dbHealthy = DBUtil.healthCheck();
        DBUtil.PoolStats pool = DBUtil.getPoolStats();

        PrintWriter out = resp.getWriter();
        out.println("{");
        out.println("  \"status\": \"" + (dbHealthy ? "UP" : "DOWN") + "\",");
        out.println("  \"database\": {");
        out.println("    \"connected\": " + dbHealthy + ",");
        out.println("    \"pool\": {");
        out.println("      \"active\": " + pool.active + ",");
        out.println("      \"idle\": " + pool.idle + ",");
        out.println("      \"total\": " + pool.total + ",");
        out.println("      \"waiting\": " + pool.waiting);
        out.println("    }");
        out.println("  },");
        out.println("  \"timestamp\": \"" + java.time.Instant.now().toString() + "\"");
        out.println("}");

        resp.setStatus(dbHealthy ? 200 : 503);
    }
}