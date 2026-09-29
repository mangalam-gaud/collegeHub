package com.college.model;

public class LibraryMember {
    private int id;
    private int userId;
    private String memberType;
    private String membershipNumber;
    private String joinDate;
    private String expiryDate;
    private int maxBooksAllowed;
    private int maxIssueDays;
    private double finePerDay;
    private double maxFine;
    private boolean active;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getMemberType() { return memberType; }
    public void setMemberType(String memberType) { this.memberType = memberType; }
    public String getMembershipNumber() { return membershipNumber; }
    public void setMembershipNumber(String membershipNumber) { this.membershipNumber = membershipNumber; }
    public String getJoinDate() { return joinDate; }
    public void setJoinDate(String joinDate) { this.joinDate = joinDate; }
    public String getExpiryDate() { return expiryDate; }
    public void setExpiryDate(String expiryDate) { this.expiryDate = expiryDate; }
    public int getMaxBooksAllowed() { return maxBooksAllowed; }
    public void setMaxBooksAllowed(int maxBooksAllowed) { this.maxBooksAllowed = maxBooksAllowed; }
    public int getMaxIssueDays() { return maxIssueDays; }
    public void setMaxIssueDays(int maxIssueDays) { this.maxIssueDays = maxIssueDays; }
    public double getFinePerDay() { return finePerDay; }
    public void setFinePerDay(double finePerDay) { this.finePerDay = finePerDay; }
    public double getMaxFine() { return maxFine; }
    public void setMaxFine(double maxFine) { this.maxFine = maxFine; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}