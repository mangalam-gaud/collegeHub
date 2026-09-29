package com.college.model;

public class ExamResult {
    private int id;
    private int examId;
    private String examName;
    private String examType;
    private int studentId;
    private String studentName;
    private String studentUsername;
    private double marksObtained;
    private double maxMarks;
    private double percentage;
    private String status;
    private int gradedBy;
    private String gradedByName;
    private String gradedAt;
    private String remarks;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }
    public String getExamName() { return examName; }
    public void setExamName(String examName) { this.examName = examName; }
    public String getExamType() { return examType; }
    public void setExamType(String examType) { this.examType = examType; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentUsername() { return studentUsername; }
    public void setStudentUsername(String studentUsername) { this.studentUsername = studentUsername; }
    public double getMarksObtained() { return marksObtained; }
    public void setMarksObtained(double marksObtained) { this.marksObtained = marksObtained; }
    public double getMaxMarks() { return maxMarks; }
    public void setMaxMarks(double maxMarks) { this.maxMarks = maxMarks; }
    public double getPercentage() { return percentage; }
    public void setPercentage(double percentage) { this.percentage = percentage; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getGradedBy() { return gradedBy; }
    public void setGradedBy(int gradedBy) { this.gradedBy = gradedBy; }
    public String getGradedByName() { return gradedByName; }
    public void setGradedByName(String gradedByName) { this.gradedByName = gradedByName; }
    public String getGradedAt() { return gradedAt; }
    public void setGradedAt(String gradedAt) { this.gradedAt = gradedAt; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}