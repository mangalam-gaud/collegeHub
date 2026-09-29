package com.college.servlet;

import com.college.dao.*;
import com.college.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/hostel/*")
public class HostelServlet extends HttpServlet {
    private final HostelDAO hostelDAO = new HostelDAO();
    private final UserDAO userDAO = new UserDAO();

    private String path(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p == null || p.equals("/")) ? "dashboard" : p.substring(1);
    }

    private void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/hostel/" + page + ".jsp").forward(req, resp);
    }

    private User me(HttpServletRequest req) { return (User) req.getSession().getAttribute("user"); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "hostels":
                req.setAttribute("hostels", hostelDAO.getAllHostels());
                view(req, resp, "hostels");
                break;
            case "hostel-form":
                String hEdit = req.getParameter("edit");
                if (hEdit != null) req.setAttribute("editHostel", hostelDAO.getHostelById(Integer.parseInt(hEdit)));
                req.setAttribute("wardens", userDAO.getByRole("HOSTEL_WARDEN"));
                view(req, resp, "hostel-form");
                break;
            case "rooms":
                String hostelId = req.getParameter("hostelId");
                if (hostelId != null) {
                    req.setAttribute("rooms", hostelDAO.getRoomsByHostel(Integer.parseInt(hostelId)));
                    req.setAttribute("hostelId", hostelId);
                }
                view(req, resp, "rooms");
                break;
            case "room-form":
                String rEdit = req.getParameter("edit");
                if (rEdit != null) req.setAttribute("editRoom", hostelDAO.getRoomById(Integer.parseInt(rEdit)));
                req.setAttribute("hostels", hostelDAO.getAllHostels());
                view(req, resp, "room-form");
                break;
            case "allocations":
                req.setAttribute("allocations", hostelDAO.getStudentAllocation(user.getId()));
                view(req, resp, "allocations");
                break;
            case "allocate":
                req.setAttribute("students", userDAO.getByRole("STUDENT"));
                req.setAttribute("rooms", hostelDAO.getAvailableRooms(1));
                view(req, resp, "allocate");
                break;
            default:
                req.setAttribute("hostels", hostelDAO.getAllHostels());
                view(req, resp, "dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = me(req);
        String action = path(req);
        switch (action) {
            case "hostel-save": {
                Hostel h = new Hostel();
                String idStr = req.getParameter("id");
                h.setName(req.getParameter("name"));
                h.setCode(req.getParameter("code"));
                h.setType(req.getParameter("type"));
                h.setWardenId(req.getParameter("wardenId") != null ? Integer.parseInt(req.getParameter("wardenId")) : 0);
                h.setAddress(req.getParameter("address"));
                h.setTotalRooms(Integer.parseInt(req.getParameter("totalRooms")));
                h.setTotalBeds(Integer.parseInt(req.getParameter("totalBeds")));
                h.setFacilities(req.getParameter("facilities"));
                h.setRules(req.getParameter("rules"));
                h.setContactPhone(req.getParameter("contactPhone"));
                h.setContactEmail(req.getParameter("contactEmail"));
                h.setActive("on".equals(req.getParameter("isActive")));
                if (idStr != null && !idStr.isBlank()) h.setId(Integer.parseInt(idStr));
                hostelDAO.createHostel(h);
                resp.sendRedirect(req.getContextPath() + "/hostel/hostels");
                break;
            }
            case "room-save": {
                HostelRoom room = new HostelRoom();
                String idStr = req.getParameter("id");
                room.setHostelId(Integer.parseInt(req.getParameter("hostelId")));
                room.setRoomNumber(req.getParameter("roomNumber"));
                room.setFloor(Integer.parseInt(req.getParameter("floor")));
                room.setRoomType(req.getParameter("roomType"));
                room.setCapacity(Integer.parseInt(req.getParameter("capacity")));
                room.setRentPerMonth(Double.parseDouble(req.getParameter("rentPerMonth")));
                room.setHasAc("on".equals(req.getParameter("hasAc")));
                room.setHasAttachedBathroom("on".equals(req.getParameter("hasAttachedBathroom")));
                room.setFurnitureDetails(req.getParameter("furnitureDetails"));
                room.setStatus(req.getParameter("status"));
                if (idStr != null && !idStr.isBlank()) room.setId(Integer.parseInt(idStr));
                hostelDAO.createRoom(room);
                resp.sendRedirect(req.getContextPath() + "/hostel/rooms?hostelId=" + room.getHostelId());
                break;
            }
            case "allocate-room": {
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                int roomId = Integer.parseInt(req.getParameter("roomId"));
                int bedNumber = Integer.parseInt(req.getParameter("bedNumber"));
                hostelDAO.allocateRoom(studentId, roomId, bedNumber, 1, user.getId());
                resp.sendRedirect(req.getContextPath() + "/hostel/allocations?allocated=1");
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/hostel/dashboard");
        }
    }
}