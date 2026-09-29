package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class LibraryDAO {

    // ========== Books ==========
    public List<LibraryBook> searchBooks(String query, int categoryId, String status, int offset, int limit) {
        List<LibraryBook> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT b.*, c.name as category_name FROM library_books b " +
                "LEFT JOIN library_categories c ON c.id=b.category_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (query != null && !query.isBlank()) {
            String like = "%" + query.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
            sql.append(" AND (b.title LIKE ? ESCAPE '\\\\' OR b.author LIKE ? ESCAPE '\\\\' OR b.isbn LIKE ? ESCAPE '\\\\')");
            params.add(like); params.add(like); params.add(like);
        }
        if (categoryId > 0) {
            sql.append(" AND b.category_id=?");
            params.add(categoryId);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND b.status=?");
            params.add(status);
        }
        sql.append(" ORDER BY b.title LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapBook(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countBooks(String query, int categoryId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM library_books b WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (query != null && !query.isBlank()) {
            String like = "%" + query.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
            sql.append(" AND (b.title LIKE ? ESCAPE '\\\\' OR b.author LIKE ? ESCAPE '\\\\' OR b.isbn LIKE ? ESCAPE '\\\\')");
            params.add(like); params.add(like); params.add(like);
        }
        if (categoryId > 0) { sql.append(" AND b.category_id=?"); params.add(categoryId); }
        if (status != null && !status.isBlank()) { sql.append(" AND b.status=?"); params.add(status); }
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) { if (r.next()) return r.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public LibraryBook getBookById(int id) {
        String sql = "SELECT b.*, c.name as category_name FROM library_books b " +
                     "LEFT JOIN library_categories c ON c.id=b.category_id WHERE b.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapBook(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createBook(LibraryBook book) {
        String sql = "INSERT INTO library_books (isbn, title, author, publisher, edition, publication_year, " +
                     "category_id, total_copies, available_copies, location_rack, location_shelf, " +
                     "price, language, pages, description, cover_image, status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, book.getIsbn());
            p.setString(2, book.getTitle());
            p.setString(3, book.getAuthor());
            p.setString(4, book.getPublisher());
            p.setString(5, book.getEdition());
            p.setInt(6, book.getPublicationYear());
            p.setInt(7, book.getCategoryId());
            p.setInt(8, book.getTotalCopies());
            p.setInt(9, book.getAvailableCopies());
            p.setString(10, book.getLocationRack());
            p.setString(11, book.getLocationShelf());
            p.setDouble(10, book.getPrice());
            p.setString(11, book.getLanguage());
            p.setInt(12, book.getPages());
            p.setString(13, book.getDescription());
            p.setString(14, book.getCoverImage());
            p.setString(15, book.getStatus());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) book.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateBook(LibraryBook book) {
        String sql = "UPDATE library_books SET isbn=?, title=?, author=?, publisher=?, edition=?, " +
                     "publication_year=?, category_id=?, total_copies=?, available_copies=?, " +
                     "location_rack=?, location_shelf=?, price=?, language=?, pages=?, " +
                     "description=?, cover_image=?, status=? WHERE id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, book.getIsbn());
            p.setString(2, book.getTitle());
            p.setString(3, book.getAuthor());
            p.setString(4, book.getPublisher());
            p.setString(5, book.getEdition());
            p.setInt(6, book.getPublicationYear());
            p.setInt(7, book.getCategoryId());
            p.setInt(8, book.getTotalCopies());
            p.setInt(9, book.getAvailableCopies());
            p.setString(10, book.getLocationRack());
            p.setString(11, book.getLocationShelf());
            p.setDouble(12, book.getPrice());
            p.setString(13, book.getLanguage());
            p.setInt(14, book.getPages());
            p.setString(15, book.getDescription());
            p.setString(16, book.getCoverImage());
            p.setString(17, book.getStatus());
            p.setInt(18, book.getId());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private LibraryBook mapBook(ResultSet r) throws SQLException {
        LibraryBook b = new LibraryBook();
        b.setId(r.getInt("id"));
        b.setIsbn(r.getString("isbn"));
        b.setTitle(r.getString("title"));
        b.setAuthor(r.getString("author"));
        b.setPublisher(r.getString("publisher"));
        b.setEdition(r.getString("edition"));
        b.setPublicationYear(r.getInt("publication_year"));
        b.setCategoryId(r.getInt("category_id"));
        b.setCategoryName(r.getString("category_name"));
        b.setTotalCopies(r.getInt("total_copies"));
        b.setAvailableCopies(r.getInt("available_copies"));
        b.setLocationRack(r.getString("location_rack"));
        b.setLocationShelf(r.getString("location_shelf"));
        b.setPrice(r.getDouble("price"));
        b.setLanguage(r.getString("language"));
        b.setPages(r.getInt("pages"));
        b.setDescription(r.getString("description"));
        b.setCoverImage(r.getString("cover_image"));
        b.setStatus(r.getString("status"));
        b.setCreatedAt(r.getString("created_at"));
        return b;
    }

    // ========== Issues ==========
    public List<LibraryIssue> getIssuesByMember(int memberId) {
        List<LibraryIssue> list = new ArrayList<>();
        String sql = "SELECT li.*, b.title as book_title, b.author as book_author, " +
                     "u.full_name as member_name, u.username as member_username, " +
                     "u2.full_name as issued_by_name, u3.full_name as returned_to_name " +
                     "FROM library_issues li " +
                     "JOIN library_books b ON b.id=li.book_id " +
                     "JOIN library_members lm ON lm.id=li.member_id " +
                     "JOIN users u ON u.id=lm.user_id " +
                     "LEFT JOIN users u2 ON u2.id=li.issued_by " +
                     "LEFT JOIN users u3 ON u3.id=li.returned_to " +
                     "WHERE li.member_id=? ORDER BY li.issue_date DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, memberId);
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapIssue(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<LibraryIssue> getAllIssues(String status, int offset, int limit) {
        List<LibraryIssue> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT li.*, b.title as book_title, b.author as book_author, " +
                "u.full_name as member_name, u.username as member_username, " +
                "u2.full_name as issued_by_name, u3.full_name as returned_to_name " +
                "FROM library_issues li " +
                "JOIN library_books b ON b.id=li.book_id " +
                "JOIN library_members lm ON lm.id=li.member_id " +
                "JOIN users u ON u.id=lm.user_id " +
                "LEFT JOIN users u2 ON u2.id=li.issued_by " +
                "LEFT JOIN users u3 ON u3.id=li.returned_to WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isBlank()) { sql.append(" AND li.status=?"); params.add(status); }
        sql.append(" ORDER BY li.issue_date DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);
        
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) p.setObject(i + 1, params.get(i));
            try (ResultSet r = p.executeQuery()) { while (r.next()) list.add(mapIssue(r)); }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public LibraryIssue getActiveIssueByBookAndMember(int bookId, int memberId) {
        String sql = "SELECT * FROM library_issues WHERE book_id=? AND member_id=? AND status IN ('ISSUED','OVERDUE')";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, bookId);
            p.setInt(2, memberId);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapIssue(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean issueBook(LibraryIssue issue) {
        Connection c = null;
        try {
            c = DBUtil.getConnection();
            c.setAutoCommit(false);
            
            // Create issue record
            String sql = "INSERT INTO library_issues (book_id, member_id, issue_date, due_date, issued_by, status) VALUES (?,?,?,?,?,?)";
            try (PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                p.setInt(1, issue.getBookId());
                p.setInt(2, issue.getMemberId());
                p.setString(3, issue.getIssueDate());
                p.setString(4, issue.getDueDate());
                p.setInt(5, issue.getIssuedBy());
                p.setString(6, "ISSUED");
                if (p.executeUpdate() != 1) { c.rollback(); return false; }
                
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) issue.setId(keys.getInt(1));
                }
            }
            
            // Update book availability
            try (PreparedStatement p = c.prepareStatement("UPDATE library_books SET available_copies=available_copies-1, status=CASE WHEN available_copies-1<=0 THEN 'ISSUED' ELSE 'AVAILABLE' END WHERE id=?")) {
                p.setInt(1, issue.getBookId());
                p.executeUpdate();
            }
            
            c.commit();
            return true;
        } catch (SQLException e) { 
            try { if (c != null) c.rollback(); } catch (SQLException ex) {}
            e.printStackTrace(); return false; 
        } finally {
            try { if (c != null) c.setAutoCommit(true); } catch (SQLException e) {}
        }
    }

    public boolean returnBook(int issueId, int returnedBy) {
        Connection c = null;
        try {
            c = DBUtil.getConnection();
            c.setAutoCommit(false);
            
            // Get issue details
            String getSql = "SELECT book_id FROM library_issues WHERE id=? AND status IN ('ISSUED','OVERDUE')";
            int bookId = 0;
            try (PreparedStatement p = c.prepareStatement(getSql)) {
                p.setInt(1, issueId);
                try (ResultSet r = p.executeQuery()) { if (r.next()) bookId = r.getInt("book_id"); }
            }
            if (bookId == 0) { c.rollback(); return false; }
            
            // Update issue
            String updSql = "UPDATE library_issues SET return_date=CURDATE(), returned_to=?, status='RETURNED' WHERE id=?";
            try (PreparedStatement p = c.prepareStatement(updSql)) {
                p.setInt(1, returnedBy);
                p.setInt(2, issueId);
                if (p.executeUpdate() != 1) { c.rollback(); return false; }
            }
            
            // Update book availability
            try (PreparedStatement p = c.prepareStatement("UPDATE library_books SET available_copies=available_copies+1, status=CASE WHEN available_copies+1>0 THEN 'AVAILABLE' ELSE 'ISSUED' END WHERE id=?")) {
                p.setInt(1, bookId);
                p.executeUpdate();
            }
            
            c.commit();
            return true;
        } catch (SQLException e) { 
            try { if (c != null) c.rollback(); } catch (SQLException ex) {}
            e.printStackTrace(); return false; 
        } finally {
            try { if (c != null) c.setAutoCommit(true); } catch (SQLException e) {}
        }
    }

    private LibraryIssue mapIssue(ResultSet r) throws SQLException {
        LibraryIssue li = new LibraryIssue();
        li.setId(r.getInt("id"));
        li.setBookId(r.getInt("book_id"));
        li.setBookTitle(r.getString("book_title"));
        li.setBookAuthor(r.getString("book_author"));
        li.setMemberId(r.getInt("member_id"));
        li.setMemberName(r.getString("member_name"));
        li.setMemberUsername(r.getString("member_username"));
        li.setIssueDate(r.getString("issue_date"));
        li.setDueDate(r.getString("due_date"));
        li.setReturnDate(r.getString("return_date"));
        li.setRenewedCount(r.getInt("renewed_count"));
        li.setMaxRenewals(r.getInt("max_renewals"));
        li.setFineAmount(r.getDouble("fine_amount"));
        li.setFinePaid(r.getInt("fine_paid") == 1);
        li.setIssuedBy(r.getInt("issued_by"));
        li.setIssuedByName(r.getString("issued_by_name"));
        li.setReturnedTo(r.getInt("returned_to"));
        li.setReturnedToName(r.getString("returned_to_name"));
        li.setStatus(r.getString("status"));
        li.setRemarks(r.getString("remarks"));
        li.setCreatedAt(r.getString("created_at"));
        return li;
    }

    // ========== Members ==========
    public LibraryMember getMemberByUserId(int userId) {
        String sql = "SELECT * FROM library_members WHERE user_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            try (ResultSet r = p.executeQuery()) { if (r.next()) return mapMember(r); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createMember(LibraryMember member) {
        String sql = "INSERT INTO library_members (user_id, member_type, membership_number, join_date, expiry_date, " +
                     "max_books_allowed, max_issue_days, fine_per_day, max_fine, is_active) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, member.getUserId());
            p.setString(2, member.getMemberType());
            p.setString(3, member.getMembershipNumber());
            p.setString(4, member.getJoinDate());
            p.setString(5, member.getExpiryDate());
            p.setInt(6, member.getMaxBooksAllowed());
            p.setInt(7, member.getMaxIssueDays());
            p.setDouble(8, member.getFinePerDay());
            p.setDouble(9, member.getMaxFine());
            p.setInt(10, member.isActive() ? 1 : 0);
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) member.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private LibraryMember mapMember(ResultSet r) throws SQLException {
        LibraryMember m = new LibraryMember();
        m.setId(r.getInt("id"));
        m.setUserId(r.getInt("user_id"));
        m.setMemberType(r.getString("member_type"));
        m.setMembershipNumber(r.getString("membership_number"));
        m.setJoinDate(r.getString("join_date"));
        m.setExpiryDate(r.getString("expiry_date"));
        m.setMaxBooksAllowed(r.getInt("max_books_allowed"));
        m.setMaxIssueDays(r.getInt("max_issue_days"));
        m.setFinePerDay(r.getDouble("fine_per_day"));
        m.setMaxFine(r.getDouble("max_fine"));
        m.setActive(r.getInt("is_active") == 1);
        m.setCreatedAt(r.getString("created_at"));
        return m;
    }
}