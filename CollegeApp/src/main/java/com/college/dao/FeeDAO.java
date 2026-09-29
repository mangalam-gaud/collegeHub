package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.*;
import com.college.util.DBUtil;

public class FeeDAO {

    // ========== Fee Structures ==========
    public List<FeeStructure> getAllFeeStructures() {
        List<FeeStructure> list = new ArrayList<>();
        String sql = "SELECT fs.*, p.name as program_name, ay.name as academic_year_name " +
                     "FROM fee_structures fs " +
                     "LEFT JOIN programs p ON p.id=fs.program_id " +
                     "LEFT JOIN academic_years ay ON ay.id=fs.academic_year_id " +
                     "WHERE fs.is_active=1 ORDER BY ay.name DESC, fs.name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapFeeStructure(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<FeeStructure> getFeeStructuresByProgramAndSemester(int programId, int semester, int academicYearId) {
        List<FeeStructure> list = new ArrayList<>();
        String sql = "SELECT fs.*, p.name as program_name, ay.name as academic_year_name " +
                     "FROM fee_structures fs " +
                     "LEFT JOIN programs p ON p.id=fs.program_id " +
                     "LEFT JOIN academic_years ay ON ay.id=fs.academic_year_id " +
                     "WHERE fs.program_id=? AND fs.semester=? AND fs.academic_year_id=? AND fs.is_active=1";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, programId);
            p.setInt(2, semester);
            p.setInt(3, academicYearId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapFeeStructure(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public FeeStructure getFeeStructureById(int id) {
        String sql = "SELECT fs.*, p.name as program_name, ay.name as academic_year_name " +
                     "FROM fee_structures fs " +
                     "LEFT JOIN programs p ON p.id=fs.program_id " +
                     "LEFT JOIN academic_years ay ON ay.id=fs.academic_year_id " +
                     "WHERE fs.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapFeeStructure(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public FeeStructure getApplicableFeeStructure(int studentId) {
        String sql = "SELECT fs.*, p.name as program_name, ay.name as academic_year_name " +
                     "FROM fee_structures fs " +
                     "JOIN users u ON u.id=? " +
                     "JOIN student_profiles sp ON sp.user_id=u.id " +
                     "JOIN programs p ON p.id=sp.program_id " +
                     "JOIN academic_years ay ON ay.id=fs.academic_year_id " +
                     "WHERE fs.program_id=sp.program_id " +
                     "AND fs.semester=sp.current_semester " +
                     "AND fs.category=sp.category " +
                     "AND fs.is_active=1 " +
                     "ORDER BY fs.id DESC LIMIT 1";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapFeeStructure(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createFeeStructure(FeeStructure fs) {
        String sql = "INSERT INTO fee_structures (name, program_id, semester, category, academic_year_id, " +
                     "tuition_fee, lab_fee, library_fee, sports_fee, exam_fee, development_fee, " +
                     "hostel_fee, transport_fee, misc_fee, due_date, late_fee_per_day, max_late_fee, is_active) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, fs.getName());
            p.setInt(2, fs.getProgramId());
            p.setInt(3, fs.getSemester());
            p.setString(4, fs.getCategory());
            p.setInt(5, fs.getAcademicYearId());
            p.setDouble(6, fs.getTuitionFee());
            p.setDouble(7, fs.getLabFee());
            p.setDouble(8, fs.getLibraryFee());
            p.setDouble(9, fs.getSportsFee());
            p.setDouble(10, fs.getExamFee());
            p.setDouble(11, fs.getDevelopmentFee());
            p.setDouble(12, fs.getHostelFee());
            p.setDouble(13, fs.getTransportFee());
            p.setDouble(14, fs.getMiscFee());
            p.setString(15, fs.getDueDate());
            p.setDouble(16, fs.getLateFeePerDay());
            p.setDouble(17, fs.getMaxLateFee());
            p.setInt(18, fs.isActive() ? 1 : 0);
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) fs.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private FeeStructure mapFeeStructure(ResultSet r) throws SQLException {
        FeeStructure fs = new FeeStructure();
        fs.setId(r.getInt("id"));
        fs.setName(r.getString("name"));
        fs.setProgramId(r.getInt("program_id"));
        fs.setProgramName(r.getString("program_name"));
        fs.setSemester(r.getInt("semester"));
        fs.setCategory(r.getString("category"));
        fs.setAcademicYearId(r.getInt("academic_year_id"));
        fs.setAcademicYearName(r.getString("academic_year_name"));
        fs.setTuitionFee(r.getDouble("tuition_fee"));
        fs.setLabFee(r.getDouble("lab_fee"));
        fs.setLibraryFee(r.getDouble("library_fee"));
        fs.setSportsFee(r.getDouble("sports_fee"));
        fs.setExamFee(r.getDouble("exam_fee"));
        fs.setDevelopmentFee(r.getDouble("development_fee"));
        fs.setHostelFee(r.getDouble("hostel_fee"));
        fs.setTransportFee(r.getDouble("transport_fee"));
        fs.setMiscFee(r.getDouble("misc_fee"));
        fs.setTotalFee(r.getDouble("total_fee"));
        fs.setDueDate(r.getString("due_date"));
        fs.setLateFeePerDay(r.getDouble("late_fee_per_day"));
        fs.setMaxLateFee(r.getDouble("max_late_fee"));
        fs.setActive(r.getInt("is_active") == 1);
        fs.setCreatedAt(r.getString("created_at"));
        return fs;
    }

    // ========== Fee Payments ==========
    public List<FeePayment> getFeePaymentsByStudent(int studentId) {
        List<FeePayment> list = new ArrayList<>();
        // mapFeePayment reads student_name/student_username, so both must be
        // selected here. Without them the mapper throws, the catch swallows it,
        // and the student silently sees a zero paid total.
        String sql = "SELECT fp.*, u.full_name as student_name, u.username as student_username, " +
                     "fs.name as fee_structure_name, u2.full_name as received_by_name " +
                     "FROM fee_payments fp " +
                     "JOIN users u ON u.id=fp.student_id " +
                     "JOIN fee_structures fs ON fs.id=fp.fee_structure_id " +
                     "LEFT JOIN users u2 ON u2.id=fp.received_by " +
                     "WHERE fp.student_id=? ORDER BY fp.payment_date DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapFeePayment(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<FeePayment> getAllFeePayments() {
        List<FeePayment> list = new ArrayList<>();
        String sql = "SELECT fp.*, u.full_name as student_name, u.username as student_username, " +
                     "fs.name as fee_structure_name, u2.full_name as received_by_name " +
                     "FROM fee_payments fp " +
                     "JOIN users u ON u.id=fp.student_id " +
                     "JOIN fee_structures fs ON fs.id=fp.fee_structure_id " +
                     "LEFT JOIN users u2 ON u2.id=fp.received_by " +
                     "ORDER BY fp.payment_date DESC";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapFeePayment(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public FeePayment getFeePaymentById(int id) {
        String sql = "SELECT fp.*, fs.name as fee_structure_name, u.full_name as student_name, " +
                     "u.username as student_username, u2.full_name as received_by_name " +
                     "FROM fee_payments fp " +
                     "JOIN fee_structures fs ON fs.id=fp.fee_structure_id " +
                     "JOIN users u ON u.id=fp.student_id " +
                     "LEFT JOIN users u2 ON u2.id=fp.received_by " +
                     "WHERE fp.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapFeePayment(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean recordFeePayment(FeePayment fp) {
        String sql = "INSERT INTO fee_payments (student_id, fee_structure_id, payment_date, amount_paid, " +
                     "payment_mode, transaction_ref, receipt_number, received_by, status, late_fee, discount, remarks) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, fp.getStudentId());
            p.setInt(2, fp.getFeeStructureId());
            p.setTimestamp(3, Timestamp.valueOf(fp.getPaymentDate()));
            p.setDouble(4, fp.getAmountPaid());
            p.setString(5, fp.getPaymentMode());
            p.setString(6, fp.getTransactionRef());
            p.setString(7, fp.getReceiptNumber());
            p.setInt(8, fp.getReceivedBy());
            p.setString(9, fp.getStatus());
            p.setDouble(10, fp.getLateFee());
            p.setDouble(11, fp.getDiscount());
            p.setString(12, fp.getRemarks());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) fp.setId(keys.getInt(1));
                }
                DBUtil.auditDataChange("fee_payments", "CREATE", fp.getId(), fp.getReceivedBy(), 
                    null, "student=" + fp.getStudentId() + ", amount=" + fp.getAmountPaid());
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public double getTotalPaidByStudent(int studentId, int feeStructureId) {
        String sql = "SELECT COALESCE(SUM(amount_paid),0) FROM fee_payments " +
                     "WHERE student_id=? AND fee_structure_id=? AND status='COMPLETED'";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, studentId);
            p.setInt(2, feeStructureId);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return r.getDouble(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    private FeePayment mapFeePayment(ResultSet r) throws SQLException {
        FeePayment fp = new FeePayment();
        fp.setId(r.getInt("id"));
        fp.setStudentId(r.getInt("student_id"));
        fp.setStudentName(r.getString("student_name"));
        fp.setStudentUsername(r.getString("student_username"));
        fp.setFeeStructureId(r.getInt("fee_structure_id"));
        fp.setFeeStructureName(r.getString("fee_structure_name"));
        fp.setPaymentDate(r.getString("payment_date"));
        fp.setAmountPaid(r.getDouble("amount_paid"));
        fp.setPaymentMode(r.getString("payment_mode"));
        fp.setTransactionRef(r.getString("transaction_ref"));
        fp.setReceiptNumber(r.getString("receipt_number"));
        fp.setReceivedBy(r.getInt("received_by"));
        fp.setReceivedByName(r.getString("received_by_name"));
        fp.setStatus(r.getString("status"));
        fp.setLateFee(r.getDouble("late_fee"));
        fp.setDiscount(r.getDouble("discount"));
        fp.setRemarks(r.getString("remarks"));
        fp.setCreatedAt(r.getString("created_at"));
        return fp;
    }

    // ========== Scholarships ==========
    public List<Scholarship> getAllScholarships() {
        List<Scholarship> list = new ArrayList<>();
        String sql = "SELECT s.*, ay.name as academic_year_name FROM scholarships s " +
                     "LEFT JOIN academic_years ay ON ay.id=s.academic_year_id " +
                     "WHERE s.is_active=1 ORDER BY s.name";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) list.add(mapScholarship(r));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Scholarship getScholarshipById(int id) {
        String sql = "SELECT s.*, ay.name as academic_year_name FROM scholarships s " +
                     "LEFT JOIN academic_years ay ON ay.id=s.academic_year_id WHERE s.id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, id);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapScholarship(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean createScholarship(Scholarship s) {
        String sql = "INSERT INTO scholarships (name, code, description, eligibility_criteria, " +
                     "amount_type, amount_value, max_recipients, academic_year_id, " +
                     "application_start, application_end, is_active) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setString(1, s.getName());
            p.setString(2, s.getCode());
            p.setString(3, s.getDescription());
            p.setString(4, s.getEligibilityCriteria());
            p.setString(5, s.getAmountType());
            p.setDouble(6, s.getAmountValue());
            p.setInt(7, s.getMaxRecipients());
            p.setInt(8, s.getAcademicYearId());
            p.setString(9, s.getApplicationStart());
            p.setString(10, s.getApplicationEnd());
            p.setInt(11, s.isActive() ? 1 : 0);
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) s.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    private Scholarship mapScholarship(ResultSet r) throws SQLException {
        Scholarship s = new Scholarship();
        s.setId(r.getInt("id"));
        s.setName(r.getString("name"));
        s.setCode(r.getString("code"));
        s.setDescription(r.getString("description"));
        s.setEligibilityCriteria(r.getString("eligibility_criteria"));
        s.setAmountType(r.getString("amount_type"));
        s.setAmountValue(r.getDouble("amount_value"));
        s.setMaxRecipients(r.getInt("max_recipients"));
        s.setAcademicYearId(r.getInt("academic_year_id"));
        s.setAcademicYearName(r.getString("academic_year_name"));
        s.setApplicationStart(r.getString("application_start"));
        s.setApplicationEnd(r.getString("application_end"));
        s.setActive(r.getInt("is_active") == 1);
        s.setCreatedAt(r.getString("created_at"));
        return s;
    }
}