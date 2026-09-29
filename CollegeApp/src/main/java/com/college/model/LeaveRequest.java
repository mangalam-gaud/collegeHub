package com.college.model;

public class LeaveRequest {
    private int id;
    private int userId;
    private String userName;
    private String userRole;
    private int leaveTypeId;
    private String leaveTypeName;
    private String startDate;
    private String endDate;
    private double totalDays;
    private String reason;
    private String contactDuringLeave;
    private String status;
    private String appliedAt;
    private int reviewedBy;
    private String reviewedByName;
    private String reviewedAt;
    private String reviewerRemarks;
    private String supportingDocument;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
    public int getLeaveTypeId() { return leaveTypeId; }
    public void setLeaveTypeId(int leaveTypeId) { this.leaveTypeId = leaveTypeId; }
    public String getLeaveTypeName() { return leaveTypeName; }
    public void setLeaveTypeName(String leaveTypeName) { this.leaveTypeName = leaveTypeName; }
    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
    public double getTotalDays() { return totalDays; }
    public void setTotalDays(double totalDays) { this.totalDays = totalDays; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getContactDuringLeave() { return contactDuringLeave; }
    public void setContactDuringLeave(String contactDuringLeave) { this.contactDuringLeave = contactDuringLeave; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAppliedAt() { return appliedAt; }
    public void setAppliedAt(String appliedAt) { this.appliedAt = appliedAt; }
    public int getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(int reviewedBy) { this.reviewedBy = reviewedBy; }
    public String getReviewedByName() { return reviewedByName; }
    public void setReviewedByName(String reviewedByName) { this.reviewedByName = reviewedByName; }
    public String getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(String reviewedAt) { this.reviewedAt = reviewedAt; }
    public String getReviewerRemarks() { return reviewerRemarks; }
    public void setReviewerRemarks(String reviewerRemarks) { this.reviewerRemarks = reviewerRemarks; }
    public String getSupportingDocument() { return supportingDocument; }
    public void setSupportingDocument(String supportingDocument) { this.supportingDocument = supportingDocument; }
}