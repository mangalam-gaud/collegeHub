package com.college.model;

public class HostelRoom {
    private int id;
    private int hostelId;
    private String hostelName;
    private String roomNumber;
    private int floor;
    private String roomType;
    private int capacity;
    private int occupiedBeds;
    private double rentPerMonth;
    private boolean hasAc;
    private boolean hasAttachedBathroom;
    private String furnitureDetails;
    private String status;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getHostelId() { return hostelId; }
    public void setHostelId(int hostelId) { this.hostelId = hostelId; }
    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public int getFloor() { return floor; }
    public void setFloor(int floor) { this.floor = floor; }
    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public int getOccupiedBeds() { return occupiedBeds; }
    public void setOccupiedBeds(int occupiedBeds) { this.occupiedBeds = occupiedBeds; }
    public int getAvailableBeds() { return capacity - occupiedBeds; }
    public double getRentPerMonth() { return rentPerMonth; }
    public void setRentPerMonth(double rentPerMonth) { this.rentPerMonth = rentPerMonth; }
    public boolean isHasAc() { return hasAc; }
    public void setHasAc(boolean hasAc) { this.hasAc = hasAc; }
    public boolean isHasAttachedBathroom() { return hasAttachedBathroom; }
    public void setHasAttachedBathroom(boolean hasAttachedBathroom) { this.hasAttachedBathroom = hasAttachedBathroom; }
    public String getFurnitureDetails() { return furnitureDetails; }
    public void setFurnitureDetails(String furnitureDetails) { this.furnitureDetails = furnitureDetails; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}