package com.college.model;

public class Message {
    private int id;
    private int senderId;
    private String senderName;
    private String senderRole;
    private int recipientId;
    private String recipientName;
    private String subject;
    private String body;
    private String messageType;
    private String priority;
    private boolean read;
    private String readAt;
    private int parentMessageId;
    private String attachmentPath;
    private String sentAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }
    public int getRecipientId() { return recipientId; }
    public void setRecipientId(int recipientId) { this.recipientId = recipientId; }
    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }
    public String getReadAt() { return readAt; }
    public void setReadAt(String readAt) { this.readAt = readAt; }
    public int getParentMessageId() { return parentMessageId; }
    public void setParentMessageId(int parentMessageId) { this.parentMessageId = parentMessageId; }
    public String getAttachmentPath() { return attachmentPath; }
    public void setAttachmentPath(String attachmentPath) { this.attachmentPath = attachmentPath; }
    public String getSentAt() { return sentAt; }
    public void setSentAt(String sentAt) { this.sentAt = sentAt; }
}