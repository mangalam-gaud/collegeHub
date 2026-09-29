package com.college.model;

public class FeePayment {
    private int id;
    private int studentId;
    private String studentName;
    private String studentUsername;
    private int feeStructureId;
    private String feeStructureName;
    private String paymentDate;
    private double amountPaid;
    private String paymentMode;
    private String transactionRef;
    private String receiptNumber;
    private int receivedBy;
    private String receivedByName;
    private String status;
    private double lateFee;
    private double discount;
    private String remarks;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentUsername() { return studentUsername; }
    public void setStudentUsername(String studentUsername) { this.studentUsername = studentUsername; }
    public int getFeeStructureId() { return feeStructureId; }
    public void setFeeStructureId(int feeStructureId) { this.feeStructureId = feeStructureId; }
    public String getFeeStructureName() { return feeStructureName; }
    public void setFeeStructureName(String feeStructureName) { this.feeStructureName = feeStructureName; }
    public String getPaymentDate() { return paymentDate; }
    public void setPaymentDate(String paymentDate) { this.paymentDate = paymentDate; }
    public double getAmountPaid() { return amountPaid; }
    public void setAmountPaid(double amountPaid) { this.amountPaid = amountPaid; }
    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }
    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }
    public String getReceiptNumber() { return receiptNumber; }
    public void setReceiptNumber(String receiptNumber) { this.receiptNumber = receiptNumber; }
    public int getReceivedBy() { return receivedBy; }
    public void setReceivedBy(int receivedBy) { this.receivedBy = receivedBy; }
    public String getReceivedByName() { return receivedByName; }
    public void setReceivedByName(String receivedByName) { this.receivedByName = receivedByName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public double getLateFee() { return lateFee; }
    public void setLateFee(double lateFee) { this.lateFee = lateFee; }
    public double getDiscount() { return discount; }
    public void setDiscount(double discount) { this.discount = discount; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}