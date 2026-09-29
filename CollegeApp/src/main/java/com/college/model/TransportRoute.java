package com.college.model;

import java.util.ArrayList;
import java.util.List;

public class TransportRoute {
    private int id;
    private String name;
    private String code;
    private String description;
    private String startPoint;
    private String endPoint;
    private double distanceKm;
    private int estimatedTimeMinutes;
    private double monthlyFee;
    private int driverId;
    private String driverName;
    private int conductorId;
    private String conductorName;
    private int vehicleId;
    private String vehicleNumber;
    private boolean active;
    private String createdAt;
    
    // Inner class for stops
    public static class TransportStop {
        private int id;
        private int routeId;
        private String stopName;
        private int stopOrder;
        private double latitude;
        private double longitude;
        private String arrivalTime;
        private String departureTime;
        private boolean pickup;
        private boolean drop;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public int getRouteId() { return routeId; }
        public void setRouteId(int routeId) { this.routeId = routeId; }
        public String getStopName() { return stopName; }
        public void setStopName(String stopName) { this.stopName = stopName; }
        public int getStopOrder() { return stopOrder; }
        public void setStopOrder(int stopOrder) { this.stopOrder = stopOrder; }
        public double getLatitude() { return latitude; }
        public void setLatitude(double latitude) { this.latitude = latitude; }
        public double getLongitude() { return longitude; }
        public void setLongitude(double longitude) { this.longitude = longitude; }
        public String getArrivalTime() { return arrivalTime; }
        public void setArrivalTime(String arrivalTime) { this.arrivalTime = arrivalTime; }
        public String getDepartureTime() { return departureTime; }
        public void setDepartureTime(String departureTime) { this.departureTime = departureTime; }
        public boolean isPickup() { return pickup; }
        public void setPickup(boolean pickup) { this.pickup = pickup; }
        public boolean isDrop() { return drop; }
        public void setDrop(boolean drop) { this.drop = drop; }
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStartPoint() { return startPoint; }
    public void setStartPoint(String startPoint) { this.startPoint = startPoint; }
    public String getEndPoint() { return endPoint; }
    public void setEndPoint(String endPoint) { this.endPoint = endPoint; }
    public double getDistanceKm() { return distanceKm; }
    public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }
    public int getEstimatedTimeMinutes() { return estimatedTimeMinutes; }
    public void setEstimatedTimeMinutes(int estimatedTimeMinutes) { this.estimatedTimeMinutes = estimatedTimeMinutes; }
    public double getMonthlyFee() { return monthlyFee; }
    public void setMonthlyFee(double monthlyFee) { this.monthlyFee = monthlyFee; }
    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }
    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
    public int getConductorId() { return conductorId; }
    public void setConductorId(int conductorId) { this.conductorId = conductorId; }
    public String getConductorName() { return conductorName; }
    public void setConductorName(String conductorName) { this.conductorName = conductorName; }
    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }
    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    // Transient field for stops (populated by DAO if needed)
    private transient List<TransportStop> stops = new ArrayList<>();

    // Number of stops on this route, computed by the DAO in one query so the
    // dashboard does not need an N+1 lookup per route.
    private int stopCount;

    public int getStopCount() { return stopCount; }
    public void setStopCount(int stopCount) { this.stopCount = stopCount; }

    public List<TransportStop> getStops() {
        return stops != null ? stops : new ArrayList<>();
    }

    public void setStops(List<TransportStop> stops) {
        this.stops = stops;
    }

    // Booking-related fields (transient, for display)
    private String bookingStatus;
    private String bookingStartDate;
    private String bookingEndDate;
    private String stopName;

    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }
    public String getBookingStartDate() { return bookingStartDate; }
    public void setBookingStartDate(String bookingStartDate) { this.bookingStartDate = bookingStartDate; }
    public String getBookingEndDate() { return bookingEndDate; }
    public void setBookingEndDate(String bookingEndDate) { this.bookingEndDate = bookingEndDate; }
    public String getStopName() { return stopName; }
    public void setStopName(String stopName) { this.stopName = stopName; }
}