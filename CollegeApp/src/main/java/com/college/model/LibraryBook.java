package com.college.model;

public class LibraryBook {
    private int id;
    private String isbn;
    private String title;
    private String author;
    private String publisher;
    private String edition;
    private int publicationYear;
    private int categoryId;
    private String categoryName;
    private int totalCopies;
    private int availableCopies;
    private String locationRack;
    private String locationShelf;
    private double price;
    private String language;
    private int pages;
    private String description;
    private String coverImage;
    private String status;
    private String createdAt;
    private String updatedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public String getEdition() { return edition; }
    public void setEdition(String edition) { this.edition = edition; }
    public int getPublicationYear() { return publicationYear; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public int getTotalCopies() { return totalCopies; }
    public void setTotalCopies(int totalCopies) { this.totalCopies = totalCopies; }
    public int getAvailableCopies() { return availableCopies; }
    public void setAvailableCopies(int availableCopies) { this.availableCopies = availableCopies; }
    public String getLocationRack() { return locationRack; }
    public void setLocationRack(String locationRack) { this.locationRack = locationRack; }
    public String getLocationShelf() { return locationShelf; }
    public void setLocationShelf(String locationShelf) { this.locationShelf = locationShelf; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public int getPages() { return pages; }
    public void setPages(int pages) { this.pages = pages; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}