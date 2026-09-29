package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class TransportDAO {

    public List<TransportRoute> getAllRoutes() {
        List<TransportRoute> list = new ArrayList<>();
        String sql = "SELECT tr.*, u1.full_name as driver_name, u2.full_name as conductor_name, " +
                     "tv.vehicle_number, " +
                     "(SELECT COUNT(*) FROM transport_stops s WHERE s.route_id=tr.id) as stop_count " +
                     "FROM transport_routes tr " +
                     "LEFT JOIN users u1 ON u1.id=tr.driver_id " +
                     "LEFT JOIN users u2 ON u2.id=tr.conductor_id " +
                     "LEFT JOIN transport_vehicles tv ON tv.id=tr.vehicle_id " +
                     "WHERE tr.is_active=1 ORDER BY tr.name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapRoute(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public TransportRoute getRouteById(int id) {
        String sql = "SELECT tr.*, u1.full_name as driver_name, u2.full_name as conductor_name, " +
                     "tv.vehicle_number, " +
                     "(SELECT COUNT(*) FROM transport_stops s WHERE s.route_id=tr.id) as stop_count " +
                     "FROM transport_routes tr " +
                     "LEFT JOIN users u1 ON u1.id=tr.driver_id " +
                     "LEFT JOIN users u2 ON u2.id=tr.conductor_id " +
                     "LEFT JOIN transport_vehicles tv ON tv.id=tr.vehicle_id " +
                     "WHERE tr.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapRoute(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<TransportRoute.TransportStop> getStopsByRoute(int routeId) {
        List<TransportRoute.TransportStop> list = new ArrayList<>();
        String sql = "SELECT * FROM transport_stops WHERE route_id=? ORDER BY stop_order";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, routeId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    TransportRoute.TransportStop stop = new TransportRoute.TransportStop();
                    stop.setId(r.getInt("id"));
                    stop.setRouteId(r.getInt("route_id"));
                    stop.setStopName(r.getString("stop_name"));
                    stop.setStopOrder(r.getInt("stop_order"));
                    stop.setLatitude(r.getDouble("latitude"));
                    stop.setLongitude(r.getDouble("longitude"));
                    stop.setArrivalTime(r.getString("arrival_time"));
                    stop.setDepartureTime(r.getString("departure_time"));
                    stop.setPickup(r.getInt("is_pickup") == 1);
                    stop.setDrop(r.getInt("is_drop") == 1);
                    list.add(stop);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<TransportRoute> getStudentBookings(int studentId) {
        List<TransportRoute> list = new ArrayList<>();
        String sql = "SELECT tr.*, tb.start_date, tb.end_date, tb.status as booking_status, " +
                     "ts.stop_name FROM transport_bookings tb " +
                     "JOIN transport_routes tr ON tr.id=tb.route_id " +
                     "LEFT JOIN transport_stops ts ON ts.id=tb.stop_id " +
                     "WHERE tb.student_id=? AND tb.status IN ('ACTIVE','EXPIRED') ORDER BY tb.booking_date DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    TransportRoute route = mapRoute(r);
                    route.setBookingStatus(r.getString("booking_status"));
                    route.setBookingStartDate(r.getString("start_date"));
                    route.setBookingEndDate(r.getString("end_date"));
                    route.setStopName(r.getString("stop_name"));
                    list.add(route);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean bookRoute(int studentId, int routeId, int stopId, int academicYearId) {
        TransportRoute route = getRouteById(routeId);
        if (route == null) return false;
        
        String sql = "INSERT INTO transport_bookings (student_id, route_id, stop_id, academic_year_id, " +
                     "booking_date, start_date, status, monthly_fee) VALUES (?,?,?,?,CURDATE(),CURDATE(),?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            p.setInt(2, routeId);
            p.setInt(3, stopId);
            p.setInt(4, academicYearId);
            p.setString(5, "ACTIVE");
            p.setDouble(6, route.getMonthlyFee());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private TransportRoute mapRoute(ResultSet r) throws SQLException {
        TransportRoute tr = new TransportRoute();
        // Optional column: present only on queries that include the stop count.
        try {
            tr.setStopCount(r.getInt("stop_count"));
        } catch (SQLException ignored) {
            tr.setStopCount(0);
        }
        tr.setId(r.getInt("id"));
        tr.setName(r.getString("name"));
        tr.setCode(r.getString("code"));
        tr.setDescription(r.getString("description"));
        tr.setStartPoint(r.getString("start_point"));
        tr.setEndPoint(r.getString("end_point"));
        tr.setDistanceKm(r.getDouble("distance_km"));
        tr.setEstimatedTimeMinutes(r.getInt("estimated_time_minutes"));
        tr.setMonthlyFee(r.getDouble("monthly_fee"));
        tr.setDriverId(r.getInt("driver_id"));
        tr.setDriverName(r.getString("driver_name"));
        tr.setConductorId(r.getInt("conductor_id"));
        tr.setConductorName(r.getString("conductor_name"));
        tr.setVehicleId(r.getInt("vehicle_id"));
        tr.setVehicleNumber(r.getString("vehicle_number"));
        tr.setActive(r.getInt("is_active") == 1);
        tr.setCreatedAt(r.getString("created_at"));
        return tr;
    }
}