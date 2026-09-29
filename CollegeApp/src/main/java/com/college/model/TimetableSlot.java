package com.college.model;

public class TimetableSlot {
    private int id;
    private String name;
    private String startTime;
    private String endTime;
    private String dayOfWeek;
    private int slotOrder;
    private boolean isBreak;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public int getSlotOrder() { return slotOrder; }
    public void setSlotOrder(int slotOrder) { this.slotOrder = slotOrder; }
    public boolean isBreak() { return isBreak; }
    public void setBreak(boolean isBreak) { this.isBreak = isBreak; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}