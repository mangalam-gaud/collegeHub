package com.college.model;

public class Hostel {
    private int id;
    private String name;
    private String code;
    private String type;
    private int wardenId;
    private String wardenName;
    private String address;
    private int totalRooms;
    private int totalBeds;
    private String facilities;
    private String rules;
    private String contactPhone;
    private String contactEmail;
    private boolean active;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public int getWardenId() { return wardenId; }
    public void setWardenId(int wardenId) { this.wardenId = wardenId; }
    public String getWardenName() { return wardenName; }
    public void setWardenName(String wardenName) { this.wardenName = wardenName; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public int getTotalRooms() { return totalRooms; }
    public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }
    public int getTotalBeds() { return totalBeds; }
    public void setTotalBeds(int totalBeds) { this.totalBeds = totalBeds; }
    public String getFacilities() { return facilities; }
    public void setFacilities(String facilities) { this.facilities = facilities; }
    public String getRules() { return rules; }
    public void setRules(String rules) { this.rules = rules; }
    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }
    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}