package com.college.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.college.model.StudentProfile;
import com.college.util.DBUtil;

public class StudentProfileDAO {

    public StudentProfile getProfile(int userId) {
        String sql = "SELECT sp.*, u.full_name, u.username, u.email, u.role, p.name as program_name, " +
                     "h.name as hostel_name, tr.name as transport_route_name, s.name as scholarship_name " +
                     "FROM student_profiles sp " +
                     "JOIN users u ON u.id=sp.user_id " +
                     "LEFT JOIN programs p ON p.id=sp.program_id " +
                     "LEFT JOIN hostels h ON h.id=sp.hostel_id " +
                     "LEFT JOIN transport_routes tr ON tr.id=sp.transport_route_id " +
                     "LEFT JOIN scholarships s ON s.id=sp.scholarship_id " +
                     "WHERE sp.user_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, userId);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapProfile(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public StudentProfile getProfileByStudentId(String studentId) {
        String sql = "SELECT sp.*, u.full_name, u.username, u.email, u.role, p.name as program_name, " +
                     "h.name as hostel_name, tr.name as transport_route_name, s.name as scholarship_name " +
                     "FROM student_profiles sp " +
                     "JOIN users u ON u.id=sp.user_id " +
                     "LEFT JOIN programs p ON p.id=sp.program_id " +
                     "LEFT JOIN hostels h ON h.id=sp.hostel_id " +
                     "LEFT JOIN transport_routes tr ON tr.id=sp.transport_route_id " +
                     "LEFT JOIN scholarships s ON s.id=sp.scholarship_id " +
                     "WHERE sp.student_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, studentId);
            try (ResultSet r = p.executeQuery()) {
                if (r.next()) return mapProfile(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<StudentProfile> getProfilesByProgram(int programId) {
        List<StudentProfile> list = new ArrayList<>();
        String sql = "SELECT sp.*, u.full_name, u.username, u.email, u.role, p.name as program_name, " +
                     "h.name as hostel_name, tr.name as transport_route_name, s.name as scholarship_name " +
                     "FROM student_profiles sp " +
                     "JOIN users u ON u.id=sp.user_id " +
                     "LEFT JOIN programs p ON p.id=sp.program_id " +
                     "LEFT JOIN hostels h ON h.id=sp.hostel_id " +
                     "LEFT JOIN transport_routes tr ON tr.id=sp.transport_route_id " +
                     "LEFT JOIN scholarships s ON s.id=sp.scholarship_id " +
                     "WHERE sp.program_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, programId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) list.add(mapProfile(r));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean createProfile(StudentProfile sp) {
        String sql = "INSERT INTO student_profiles (user_id, student_id, program_id, current_semester, admission_date, " +
                     "admission_type, category, nationality, religion, blood_group, aadhar_number, pan_number, " +
                     "bank_account, bank_ifsc, emergency_contact_name, emergency_contact_phone, emergency_contact_relation, " +
                     "father_name, father_occupation, father_phone, father_email, mother_name, mother_occupation, " +
                     "mother_phone, mother_email, guardian_name, guardian_phone, guardian_address, annual_income, " +
                     "is_hostel_resident, hostel_id, room_number, transport_required, transport_route_id, scholarship_id) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            p.setInt(1, sp.getUserId());
            p.setString(2, sp.getStudentId());
            p.setInt(3, sp.getProgramId());
            p.setInt(4, sp.getCurrentSemester());
            p.setString(5, sp.getAdmissionDate());
            p.setString(6, sp.getAdmissionType());
            p.setString(7, sp.getCategory());
            p.setString(8, sp.getNationality());
            p.setString(9, sp.getReligion());
            p.setString(10, sp.getBloodGroup());
            p.setString(11, sp.getAadharNumber());
            p.setString(12, sp.getPanNumber());
            p.setString(13, sp.getBankAccount());
            p.setString(14, sp.getBankIfsc());
            p.setString(15, sp.getEmergencyContactName());
            p.setString(16, sp.getEmergencyContactPhone());
            p.setString(17, sp.getEmergencyContactRelation());
            p.setString(18, sp.getFatherName());
            p.setString(19, sp.getFatherOccupation());
            p.setString(20, sp.getFatherPhone());
            p.setString(21, sp.getFatherEmail());
            p.setString(22, sp.getMotherName());
            p.setString(23, sp.getMotherOccupation());
            p.setString(24, sp.getMotherPhone());
            p.setString(25, sp.getMotherEmail());
            p.setString(26, sp.getGuardianName());
            p.setString(27, sp.getGuardianPhone());
            p.setString(28, sp.getGuardianAddress());
            p.setDouble(29, sp.getAnnualIncome());
            p.setInt(30, sp.isHostelResident() ? 1 : 0);
            p.setInt(31, sp.getHostelId());
            p.setString(32, sp.getRoomNumber());
            p.setInt(33, sp.isTransportRequired() ? 1 : 0);
            p.setInt(34, sp.getTransportRouteId());
            p.setInt(35, sp.getScholarshipId());
            int affected = p.executeUpdate();
            if (affected == 1) {
                try (ResultSet keys = p.getGeneratedKeys()) {
                    if (keys.next()) sp.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateProfile(StudentProfile sp) {
        String sql = "UPDATE student_profiles SET student_id=?, program_id=?, current_semester=?, admission_date=?, " +
                     "admission_type=?, category=?, nationality=?, religion=?, blood_group=?, aadhar_number=?, pan_number=?, " +
                     "bank_account=?, bank_ifsc=?, emergency_contact_name=?, emergency_contact_phone=?, " +
                     "emergency_contact_relation=?, father_name=?, father_occupation=?, father_phone=?, father_email=?, " +
                     "mother_name=?, mother_occupation=?, mother_phone=?, mother_email=?, guardian_name=?, " +
                     "guardian_phone=?, guardian_address=?, annual_income=?, is_hostel_resident=?, hostel_id=?, " +
                     "room_number=?, transport_required=?, transport_route_id=?, scholarship_id=? WHERE user_id=?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, sp.getStudentId());
            p.setInt(2, sp.getProgramId());
            p.setInt(3, sp.getCurrentSemester());
            p.setString(4, sp.getAdmissionDate());
            p.setString(5, sp.getAdmissionType());
            p.setString(6, sp.getCategory());
            p.setString(7, sp.getNationality());
            p.setString(8, sp.getReligion());
            p.setString(9, sp.getBloodGroup());
            p.setString(10, sp.getAadharNumber());
            p.setString(11, sp.getPanNumber());
            p.setString(12, sp.getBankAccount());
            p.setString(13, sp.getBankIfsc());
            p.setString(14, sp.getEmergencyContactName());
            p.setString(15, sp.getEmergencyContactPhone());
            p.setString(16, sp.getEmergencyContactRelation());
            p.setString(17, sp.getFatherName());
            p.setString(18, sp.getFatherOccupation());
            p.setString(19, sp.getFatherPhone());
            p.setString(20, sp.getFatherEmail());
            p.setString(21, sp.getMotherName());
            p.setString(22, sp.getMotherOccupation());
            p.setString(23, sp.getMotherPhone());
            p.setString(24, sp.getMotherEmail());
            p.setString(25, sp.getGuardianName());
            p.setString(26, sp.getGuardianPhone());
            p.setString(27, sp.getGuardianAddress());
            p.setDouble(28, sp.getAnnualIncome());
            p.setInt(29, sp.isHostelResident() ? 1 : 0);
            p.setInt(30, sp.getHostelId());
            p.setString(31, sp.getRoomNumber());
            p.setInt(32, sp.isTransportRequired() ? 1 : 0);
            p.setInt(33, sp.getTransportRouteId());
            p.setInt(34, sp.getScholarshipId());
            p.setInt(35, sp.getUserId());
            return p.executeUpdate() == 1;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private StudentProfile mapProfile(ResultSet r) throws SQLException {
        StudentProfile sp = new StudentProfile();
        sp.setId(r.getInt("id"));
        sp.setUserId(r.getInt("user_id"));
        sp.setStudentId(r.getString("student_id"));
        sp.setFullName(r.getString("full_name"));
        sp.setUsername(r.getString("username"));
        sp.setEmail(r.getString("email"));
        sp.setProgramId(r.getInt("program_id"));
        sp.setProgramName(r.getString("program_name"));
        sp.setCurrentSemester(r.getInt("current_semester"));
        sp.setAdmissionDate(r.getString("admission_date"));
        sp.setAdmissionType(r.getString("admission_type"));
        sp.setCategory(r.getString("category"));
        sp.setNationality(r.getString("nationality"));
        sp.setReligion(r.getString("religion"));
        sp.setBloodGroup(r.getString("blood_group"));
        sp.setAadharNumber(r.getString("aadhar_number"));
        sp.setPanNumber(r.getString("pan_number"));
        sp.setBankAccount(r.getString("bank_account"));
        sp.setBankIfsc(r.getString("bank_ifsc"));
        sp.setEmergencyContactName(r.getString("emergency_contact_name"));
        sp.setEmergencyContactPhone(r.getString("emergency_contact_phone"));
        sp.setEmergencyContactRelation(r.getString("emergency_contact_relation"));
        sp.setFatherName(r.getString("father_name"));
        sp.setFatherOccupation(r.getString("father_occupation"));
        sp.setFatherPhone(r.getString("father_phone"));
        sp.setFatherEmail(r.getString("father_email"));
        sp.setMotherName(r.getString("mother_name"));
        sp.setMotherOccupation(r.getString("mother_occupation"));
        sp.setMotherPhone(r.getString("mother_phone"));
        sp.setMotherEmail(r.getString("mother_email"));
        sp.setGuardianName(r.getString("guardian_name"));
        sp.setGuardianPhone(r.getString("guardian_phone"));
        sp.setGuardianAddress(r.getString("guardian_address"));
        sp.setAnnualIncome(r.getDouble("annual_income"));
        sp.setHostelResident(r.getInt("is_hostel_resident") == 1);
        sp.setHostelId(r.getInt("hostel_id"));
        sp.setHostelName(r.getString("hostel_name"));
        sp.setRoomNumber(r.getString("room_number"));
        sp.setTransportRequired(r.getInt("transport_required") == 1);
        sp.setTransportRouteId(r.getInt("transport_route_id"));
        sp.setTransportRouteName(r.getString("transport_route_name"));
        sp.setScholarshipId(r.getInt("scholarship_id"));
        sp.setScholarshipName(r.getString("scholarship_name"));
        return sp;
    }
}