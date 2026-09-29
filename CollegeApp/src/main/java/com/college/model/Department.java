package com.college.model;

public class Department {
    private int id;
    private String name;
    private String code;
    private int hodId;
    private String hodName;
    private String description;
    private String createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public int getHodId() { return hodId; }
    public void setHodId(int hodId) { this.hodId = hodId; }
    public String getHodName() { return hodName; }
    public void setHodName(String hodName) { this.hodName = hodName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}