package com.college.model;

public class Scholarship {
    private int id;
    private String name;
    private String code;
    private String description;
    private String eligibilityCriteria;
    private String amountType;
    private double amountValue;
    private int maxRecipients;
    private int academicYearId;
    private String academicYearName;
    private String applicationStart;
    private String applicationEnd;
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
    public String getEligibilityCriteria() { return eligibilityCriteria; }
    public void setEligibilityCriteria(String eligibilityCriteria) { this.eligibilityCriteria = eligibilityCriteria; }
    public String getAmountType() { return amountType; }
    public void setAmountType(String amountType) { this.amountType = amountType; }
    public double getAmountValue() { return amountValue; }
    public void setAmountValue(double amountValue) { this.amountValue = amountValue; }
    public int getMaxRecipients() { return maxRecipients; }
    public void setMaxRecipients(int maxRecipients) { this.maxRecipients = maxRecipients; }
    public int getAcademicYearId() { return academicYearId; }
    public void setAcademicYearId(int academicYearId) { this.academicYearId = academicYearId; }
    public String getAcademicYearName() { return academicYearName; }
    public void setAcademicYearName(String academicYearName) { this.academicYearName = academicYearName; }
    public String getApplicationStart() { return applicationStart; }
    public void setApplicationStart(String applicationStart) { this.applicationStart = applicationStart; }
    public String getApplicationEnd() { return applicationEnd; }
    public void setApplicationEnd(String applicationEnd) { this.applicationEnd = applicationEnd; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}