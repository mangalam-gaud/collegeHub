package com.college.model;

public class Event {
    private int id;
    private String title;
    private String description;
    private String eventType;
    private String startDatetime;
    private String endDatetime;
    private String location;
    private int organizerId;
    private String organizerName;
    private String targetAudience;
    private String specificRoles;
    private String specificDepartments;
    private String specificCourses;
    private int maxParticipants;
    private boolean registrationRequired;
    private String registrationDeadline;
    private boolean published;
    private int registeredCount;
    private String createdAt;
    private String updatedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
    public String getStartDatetime() { return startDatetime; }
    public void setStartDatetime(String startDatetime) { this.startDatetime = startDatetime; }
    public String getEndDatetime() { return endDatetime; }
    public void setEndDatetime(String endDatetime) { this.endDatetime = endDatetime; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public int getOrganizerId() { return organizerId; }
    public void setOrganizerId(int organizerId) { this.organizerId = organizerId; }
    public String getOrganizerName() { return organizerName; }
    public void setOrganizerName(String organizerName) { this.organizerName = organizerName; }
    public String getTargetAudience() { return targetAudience; }
    public void setTargetAudience(String targetAudience) { this.targetAudience = targetAudience; }
    public String getSpecificRoles() { return specificRoles; }
    public void setSpecificRoles(String specificRoles) { this.specificRoles = specificRoles; }
    public String getSpecificDepartments() { return specificDepartments; }
    public void setSpecificDepartments(String specificDepartments) { this.specificDepartments = specificDepartments; }
    public String getSpecificCourses() { return specificCourses; }
    public void setSpecificCourses(String specificCourses) { this.specificCourses = specificCourses; }
    public int getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(int maxParticipants) { this.maxParticipants = maxParticipants; }
    public boolean isRegistrationRequired() { return registrationRequired; }
    public void setRegistrationRequired(boolean registrationRequired) { this.registrationRequired = registrationRequired; }
    public String getRegistrationDeadline() { return registrationDeadline; }
    public void setRegistrationDeadline(String registrationDeadline) { this.registrationDeadline = registrationDeadline; }
    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }
    public int getRegisteredCount() { return registeredCount; }
    public void setRegisteredCount(int registeredCount) { this.registeredCount = registeredCount; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}