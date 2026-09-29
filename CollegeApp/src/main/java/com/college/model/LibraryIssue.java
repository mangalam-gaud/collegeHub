package com.college.model;

public class LibraryIssue {
    private int id;
    private int bookId;
    private String bookTitle;
    private String bookAuthor;
    private int memberId;
    private String memberName;
    private String memberUsername;
    private String issueDate;
    private String dueDate;
    private String returnDate;
    private int renewedCount;
    private int maxRenewals;
    private double fineAmount;
    private boolean finePaid;
    private int issuedBy;
    private String issuedByName;
    private int returnedTo;
    private String returnedToName;
    private String status;
    private String remarks;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    public String getBookAuthor() { return bookAuthor; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }
    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }
    public String getMemberName() { return memberName; }
    public void setMemberName(String memberName) { this.memberName = memberName; }
    public String getMemberUsername() { return memberUsername; }
    public void setMemberUsername(String memberUsername) { this.memberUsername = memberUsername; }
    public String getIssueDate() { return issueDate; }
    public void setIssueDate(String issueDate) { this.issueDate = issueDate; }
    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }
    public String getReturnDate() { return returnDate; }
    public void setReturnDate(String returnDate) { this.returnDate = returnDate; }
    public int getRenewedCount() { return renewedCount; }
    public void setRenewedCount(int renewedCount) { this.renewedCount = renewedCount; }
    public int getMaxRenewals() { return maxRenewals; }
    public void setMaxRenewals(int maxRenewals) { this.maxRenewals = maxRenewals; }
    public double getFineAmount() { return fineAmount; }
    public void setFineAmount(double fineAmount) { this.fineAmount = fineAmount; }
    public boolean isFinePaid() { return finePaid; }
    public void setFinePaid(boolean finePaid) { this.finePaid = finePaid; }
    public int getIssuedBy() { return issuedBy; }
    public void setIssuedBy(int issuedBy) { this.issuedBy = issuedBy; }
    public String getIssuedByName() { return issuedByName; }
    public void setIssuedByName(String issuedByName) { this.issuedByName = issuedByName; }
    public int getReturnedTo() { return returnedTo; }
    public void setReturnedTo(int returnedTo) { this.returnedTo = returnedTo; }
    public String getReturnedToName() { return returnedToName; }
    public void setReturnedToName(String returnedToName) { this.returnedToName = returnedToName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}