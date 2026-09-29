package com.college.model;

public class LeaveType {
    private int id;
    private String name;
    private String code;
    private String description;
    private int maxDaysPerYear;
    private boolean requiresApproval;
    private boolean isCarryForward;
    private boolean active;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getMaxDaysPerYear() { return maxDaysPerYear; }
    public void setMaxDaysPerYear(int maxDaysPerYear) { this.maxDaysPerYear = maxDaysPerYear; }
    public boolean isRequiresApproval() { return requiresApproval; }
    public void setRequiresApproval(boolean requiresApproval) { this.requiresApproval = requiresApproval; }
    public boolean isCarryForward() { return isCarryForward; }
    public void setCarryForward(boolean isCarryForward) { this.isCarryForward = isCarryForward; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}