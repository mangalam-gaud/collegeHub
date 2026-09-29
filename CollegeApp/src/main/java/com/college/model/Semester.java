package com.college.model;

public class Semester {
    private int id;
    private int academicYearId;
    private String academicYearName;
    private String name;
    private int number;
    private String startDate;
    private String endDate;
    private String registrationStart;
    private String registrationEnd;
    private String examStart;
    private String examEnd;
    private String breakStart;
    private String breakEnd;
    private boolean current;
    private boolean active;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getAcademicYearId() { return academicYearId; }
    public void setAcademicYearId(int academicYearId) { this.academicYearId = academicYearId; }
    public String getAcademicYearName() { return academicYearName; }
    public void setAcademicYearName(String academicYearName) { this.academicYearName = academicYearName; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getNumber() { return number; }
    public void setNumber(int number) { this.number = number; }
    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
    public String getRegistrationStart() { return registrationStart; }
    public void setRegistrationStart(String registrationStart) { this.registrationStart = registrationStart; }
    public String getRegistrationEnd() { return registrationEnd; }
    public void setRegistrationEnd(String registrationEnd) { this.registrationEnd = registrationEnd; }
    public String getExamStart() { return examStart; }
    public void setExamStart(String examStart) { this.examStart = examStart; }
    public String getExamEnd() { return examEnd; }
    public void setExamEnd(String examEnd) { this.examEnd = examEnd; }
    public String getBreakStart() { return breakStart; }
    public void setBreakStart(String breakStart) { this.breakStart = breakStart; }
    public String getBreakEnd() { return breakEnd; }
    public void setBreakEnd(String breakEnd) { this.breakEnd = breakEnd; }
    public boolean isCurrent() { return current; }
    public void setCurrent(boolean current) { this.current = current; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}