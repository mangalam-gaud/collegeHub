package com.college.model;

public class FeeStructure {
    private int id;
    private String name;
    private int programId;
    private String programName;
    private int semester;
    private String category;
    private int academicYearId;
    private String academicYearName;
    private double tuitionFee;
    private double labFee;
    private double libraryFee;
    private double sportsFee;
    private double examFee;
    private double developmentFee;
    private double hostelFee;
    private double transportFee;
    private double miscFee;
    private double totalFee;
    private String dueDate;
    private double lateFeePerDay;
    private double maxLateFee;
    private boolean active;
    private String createdAt;
    private String updatedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getProgramId() { return programId; }
    public void setProgramId(int programId) { this.programId = programId; }
    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }
    public int getSemester() { return semester; }
    public void setSemester(int semester) { this.semester = semester; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public int getAcademicYearId() { return academicYearId; }
    public void setAcademicYearId(int academicYearId) { this.academicYearId = academicYearId; }
    public String getAcademicYearName() { return academicYearName; }
    public void setAcademicYearName(String academicYearName) { this.academicYearName = academicYearName; }
    public double getTuitionFee() { return tuitionFee; }
    public void setTuitionFee(double tuitionFee) { this.tuitionFee = tuitionFee; }
    public double getLabFee() { return labFee; }
    public void setLabFee(double labFee) { this.labFee = labFee; }
    public double getLibraryFee() { return libraryFee; }
    public void setLibraryFee(double libraryFee) { this.libraryFee = libraryFee; }
    public double getSportsFee() { return sportsFee; }
    public void setSportsFee(double sportsFee) { this.sportsFee = sportsFee; }
    public double getExamFee() { return examFee; }
    public void setExamFee(double examFee) { this.examFee = examFee; }
    public double getDevelopmentFee() { return developmentFee; }
    public void setDevelopmentFee(double developmentFee) { this.developmentFee = developmentFee; }
    public double getHostelFee() { return hostelFee; }
    public void setHostelFee(double hostelFee) { this.hostelFee = hostelFee; }
    public double getTransportFee() { return transportFee; }
    public void setTransportFee(double transportFee) { this.transportFee = transportFee; }
    public double getMiscFee() { return miscFee; }
    public void setMiscFee(double miscFee) { this.miscFee = miscFee; }
    public double getTotalFee() { return totalFee; }
    public void setTotalFee(double totalFee) { this.totalFee = totalFee; }
    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }
    public double getLateFeePerDay() { return lateFeePerDay; }
    public void setLateFeePerDay(double lateFeePerDay) { this.lateFeePerDay = lateFeePerDay; }
    public double getMaxLateFee() { return maxLateFee; }
    public void setMaxLateFee(double maxLateFee) { this.maxLateFee = maxLateFee; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}