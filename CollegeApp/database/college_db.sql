-- =====================================================
-- CollegeHub Database Schema (MySQL 8+)
-- Run: mysql -u root -p < college_db.sql
-- =====================================================
CREATE DATABASE IF NOT EXISTS college_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE college_db;

-- =====================================================
-- CORE TABLES (Existing)
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL,
    salt VARCHAR(32) NOT NULL,
    role ENUM('ADMIN','TEACHER','STUDENT','PARENT','LIBRARIAN','ACCOUNTANT','HOSTEL_WARDEN','TRANSPORT_MANAGER') NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    gender VARCHAR(10),
    dob DATE,
    address VARCHAR(255),
    profile_image VARCHAR(255),
    active TINYINT DEFAULT 1,
    last_login TIMESTAMP NULL,
    failed_login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE NOT NULL,
    hod_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hod_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    duration_years INT DEFAULT 4,
    total_semesters INT DEFAULT 8,
    eligibility_criteria TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    credits INT DEFAULT 3,
    semester INT DEFAULT 1,
    program_id INT,
    department_id INT,
    teacher_id INT,
    max_students INT DEFAULT 60,
    is_elective TINYINT DEFAULT 0,
    prerequisites TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ENROLLED','DROPPED','COMPLETED','WITHDRAWN') DEFAULT 'ENROLLED',
    dropped_at TIMESTAMP NULL,
    grade VARCHAR(2),
    UNIQUE KEY uq_enroll (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    att_date DATE NOT NULL,
    status ENUM('PRESENT','ABSENT','LATE','EXCUSED') NOT NULL,
    marked_by INT,
    remarks VARCHAR(255),
    UNIQUE KEY uq_att (student_id, course_id, att_date),
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (marked_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS marks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    exam_type VARCHAR(30) NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    max_marks DECIMAL(5,2) DEFAULT 100,
    weightage DECIMAL(3,2) DEFAULT 1.00,
    entered_by INT,
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_mark (student_id, course_id, exam_type),
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (entered_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    posted_by INT NOT NULL,
    audience ENUM('ALL','STUDENT','TEACHER','PARENT','STAFF') DEFAULT 'ALL',
    priority ENUM('LOW','NORMAL','HIGH','URGENT') DEFAULT 'NORMAL',
    published_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    is_pinned TINYINT DEFAULT 0,
    attachment_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (posted_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Default admin: username=admin  password=admin123
-- hash = SHA-256("collegehub-salt" + "admin123")
INSERT INTO users (username, email, password_hash, salt, role, full_name)
SELECT 'admin','admin@college.edu',
       'fa2c357152a10b96e2b3693886584da9294d70f363a9f388b4f1b11f90ffe0f4',
       'collegehub-salt','ADMIN','System Administrator'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='admin');

-- =====================================================
-- ACADEMIC MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS academic_years (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current TINYINT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ay_name (name)
);

CREATE TABLE IF NOT EXISTS semesters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT NOT NULL,
    name VARCHAR(30) NOT NULL,
    number INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_start DATE,
    registration_end DATE,
    exam_start DATE,
    exam_end DATE,
    break_start DATE,
    break_end DATE,
    is_current TINYINT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
    UNIQUE KEY uq_sem (academic_year_id, number)
);

CREATE TABLE IF NOT EXISTS timetable_slots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    day_of_week ENUM('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') NOT NULL,
    slot_order INT DEFAULT 0,
    is_break TINYINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS timetable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    slot_id INT NOT NULL,
    room VARCHAR(50),
    building VARCHAR(50),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_recurring TINYINT DEFAULT 1,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES timetable_slots(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS exams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    exam_type ENUM('MIDTERM','FINAL','QUIZ','ASSIGNMENT','PROJECT','PRACTICAL','VIVA') NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    building VARCHAR(50),
    max_marks DECIMAL(5,2) DEFAULT 100,
    passing_marks DECIMAL(5,2) DEFAULT 40,
    instructions TEXT,
    status ENUM('SCHEDULED','ONGOING','COMPLETED','CANCELLED','POSTPONED') DEFAULT 'SCHEDULED',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS exam_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    student_id INT NOT NULL,
    marks_obtained DECIMAL(5,2),
    status ENUM('APPEARED','ABSENT','MALPRACTICE','WITHHELD') DEFAULT 'APPEARED',
    graded_by INT,
    graded_at TIMESTAMP NULL,
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (graded_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uq_exam_result (exam_id, student_id)
);

-- =====================================================
-- STUDENT PROFILE EXTENSIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS student_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    student_id VARCHAR(20) UNIQUE NOT NULL,
    program_id INT,
    current_semester INT DEFAULT 1,
    admission_date DATE,
    admission_type ENUM('REGULAR','LATERAL','TRANSFER','EXCHANGE') DEFAULT 'REGULAR',
    category ENUM('GENERAL','OBC','SC','ST','EWS','PH') DEFAULT 'GENERAL',
    nationality VARCHAR(50) DEFAULT 'Indian',
    religion VARCHAR(50),
    blood_group VARCHAR(5),
    aadhar_number VARCHAR(14),
    pan_number VARCHAR(10),
    bank_account VARCHAR(30),
    bank_ifsc VARCHAR(15),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(50),
    father_name VARCHAR(100),
    father_occupation VARCHAR(100),
    father_phone VARCHAR(20),
    father_email VARCHAR(100),
    mother_name VARCHAR(100),
    mother_occupation VARCHAR(100),
    mother_phone VARCHAR(20),
    mother_email VARCHAR(100),
    guardian_name VARCHAR(100),
    guardian_phone VARCHAR(20),
    guardian_address TEXT,
    annual_income DECIMAL(12,2),
    is_hostel_resident TINYINT DEFAULT 0,
    hostel_id INT,
    room_number VARCHAR(20),
    transport_required TINYINT DEFAULT 0,
    transport_route_id INT,
    scholarship_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS student_documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    document_type ENUM('PHOTO','SIGNATURE','AADHAR','PAN','MARKSHEET_10','MARKSHEET_12','TRANSFER_CERT','MIGRATION_CERT','CASTE_CERT','INCOME_CERT','DOMICILE_CERT','MEDICAL_CERT','OTHER') NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_name VARCHAR(100) NOT NULL,
    file_size INT,
    mime_type VARCHAR(50),
    is_verified TINYINT DEFAULT 0,
    verified_by INT,
    verified_at TIMESTAMP NULL,
    remarks VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
);

-- =====================================================
-- FEE MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS fee_structures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    program_id INT,
    semester INT,
    category ENUM('GENERAL','OBC','SC','ST','EWS','PH') DEFAULT 'GENERAL',
    academic_year_id INT NOT NULL,
    tuition_fee DECIMAL(10,2) DEFAULT 0,
    lab_fee DECIMAL(10,2) DEFAULT 0,
    library_fee DECIMAL(10,2) DEFAULT 0,
    sports_fee DECIMAL(10,2) DEFAULT 0,
    exam_fee DECIMAL(10,2) DEFAULT 0,
    development_fee DECIMAL(10,2) DEFAULT 0,
    hostel_fee DECIMAL(10,2) DEFAULT 0,
    transport_fee DECIMAL(10,2) DEFAULT 0,
    misc_fee DECIMAL(10,2) DEFAULT 0,
    total_fee DECIMAL(10,2) GENERATED ALWAYS AS (
        tuition_fee + lab_fee + library_fee + sports_fee + exam_fee + 
        development_fee + hostel_fee + transport_fee + misc_fee
    ) STORED,
    due_date DATE,
    late_fee_per_day DECIMAL(6,2) DEFAULT 10.00,
    max_late_fee DECIMAL(10,2) DEFAULT 1000.00,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE SET NULL,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS fee_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    fee_structure_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_mode ENUM('CASH','CARD','UPI','NEFT','RTGS','CHEQUE','DD','ONLINE') NOT NULL,
    transaction_ref VARCHAR(100),
    receipt_number VARCHAR(30) UNIQUE NOT NULL,
    received_by INT,
    status ENUM('PENDING','COMPLETED','FAILED','REFUNDED','PARTIAL') DEFAULT 'COMPLETED',
    late_fee DECIMAL(8,2) DEFAULT 0,
    discount DECIMAL(8,2) DEFAULT 0,
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id) ON DELETE CASCADE,
    FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS scholarships (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    eligibility_criteria TEXT,
    amount_type ENUM('FIXED','PERCENTAGE') DEFAULT 'FIXED',
    amount_value DECIMAL(10,2) NOT NULL,
    max_recipients INT,
    academic_year_id INT NOT NULL,
    application_start DATE,
    application_end DATE,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS scholarship_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    scholarship_id INT NOT NULL,
    student_id INT NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING','APPROVED','REJECTED','REVOKED') DEFAULT 'PENDING',
    reviewed_by INT,
    reviewed_at TIMESTAMP NULL,
    remarks TEXT,
    FOREIGN KEY (scholarship_id) REFERENCES scholarships(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uq_scholarship_app (scholarship_id, student_id)
);

-- =====================================================
-- LIBRARY MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS library_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS library_books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publisher VARCHAR(100),
    edition VARCHAR(20),
    publication_year INT,
    category_id INT,
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    location_rack VARCHAR(50),
    location_shelf VARCHAR(50),
    price DECIMAL(10,2),
    language VARCHAR(30) DEFAULT 'English',
    pages INT,
    description TEXT,
    cover_image VARCHAR(255),
    status ENUM('AVAILABLE','ISSUED','RESERVED','LOST','DAMAGED','WITHDRAWN') DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES library_categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS library_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    member_type ENUM('STUDENT','TEACHER','STAFF','EXTERNAL') NOT NULL,
    membership_number VARCHAR(20) UNIQUE NOT NULL,
    join_date DATE NOT NULL,
    expiry_date DATE,
    max_books_allowed INT DEFAULT 3,
    max_issue_days INT DEFAULT 14,
    fine_per_day DECIMAL(6,2) DEFAULT 5.00,
    max_fine DECIMAL(8,2) DEFAULT 500.00,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS library_issues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    renewed_count INT DEFAULT 0,
    max_renewals INT DEFAULT 2,
    fine_amount DECIMAL(8,2) DEFAULT 0,
    fine_paid TINYINT DEFAULT 0,
    issued_by INT,
    returned_to INT,
    status ENUM('ISSUED','RETURNED','OVERDUE','LOST','DAMAGED') DEFAULT 'ISSUED',
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES library_books(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES library_members(id) ON DELETE CASCADE,
    FOREIGN KEY (issued_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (returned_to) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS library_reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    status ENUM('ACTIVE','FULFILLED','EXPIRED','CANCELLED') DEFAULT 'ACTIVE',
    notified_at TIMESTAMP NULL,
    FOREIGN KEY (book_id) REFERENCES library_books(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES library_members(id) ON DELETE CASCADE
);

-- =====================================================
-- HOSTEL MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS hostels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    type ENUM('BOYS','GIRLS','COED') NOT NULL,
    warden_id INT,
    address TEXT,
    total_rooms INT DEFAULT 0,
    total_beds INT DEFAULT 0,
    facilities TEXT,
    rules TEXT,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warden_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS hostel_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostel_id INT NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    floor INT DEFAULT 0,
    room_type ENUM('SINGLE','DOUBLE','TRIPLE','QUAD','DORMITORY') DEFAULT 'DOUBLE',
    capacity INT DEFAULT 2,
    occupied_beds INT DEFAULT 0,
    rent_per_month DECIMAL(8,2) DEFAULT 0,
    has_ac TINYINT DEFAULT 0,
    has_attached_bathroom TINYINT DEFAULT 0,
    furniture_details TEXT,
    status ENUM('AVAILABLE','OCCUPIED','PARTIAL','MAINTENANCE','RESERVED') DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hostel_id) REFERENCES hostels(id) ON DELETE CASCADE,
    UNIQUE KEY uq_hostel_room (hostel_id, room_number)
);

CREATE TABLE IF NOT EXISTS hostel_allocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    room_id INT NOT NULL,
    bed_number INT DEFAULT 1,
    allocated_date DATE NOT NULL,
    vacated_date DATE NULL,
    academic_year_id INT,
    status ENUM('ACTIVE','VACATED','TRANSFERRED','EXPELLED') DEFAULT 'ACTIVE',
    allocated_by INT,
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES hostel_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE SET NULL,
    FOREIGN KEY (allocated_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS hostel_visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    visitor_name VARCHAR(100) NOT NULL,
    visitor_phone VARCHAR(20),
    visitor_id_proof VARCHAR(50),
    purpose VARCHAR(255),
    check_in TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    check_out TIMESTAMP NULL,
    approved_by INT,
    status ENUM('PENDING','APPROVED','REJECTED','CHECKED_IN','CHECKED_OUT') DEFAULT 'PENDING',
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

-- =====================================================
-- TRANSPORT MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS transport_routes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    start_point VARCHAR(100),
    end_point VARCHAR(100),
    distance_km DECIMAL(6,2),
    estimated_time_minutes INT,
    monthly_fee DECIMAL(8,2) DEFAULT 0,
    driver_id INT,
    conductor_id INT,
    vehicle_id INT,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (conductor_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS transport_vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type ENUM('BUS','VAN','CAR','OTHER') DEFAULT 'BUS',
    capacity INT NOT NULL,
    model VARCHAR(50),
    manufacturer VARCHAR(50),
    registration_date DATE,
    insurance_expiry DATE,
    fitness_expiry DATE,
    permit_expiry DATE,
    fuel_type ENUM('DIESEL','PETROL','CNG','ELECTRIC') DEFAULT 'DIESEL',
    status ENUM('ACTIVE','MAINTENANCE','RETIRED','SOLD') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transport_stops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    stop_name VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    arrival_time TIME,
    departure_time TIME,
    is_pickup TINYINT DEFAULT 1,
    is_drop TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (route_id) REFERENCES transport_routes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS transport_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    route_id INT NOT NULL,
    stop_id INT,
    academic_year_id INT,
    booking_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('ACTIVE','CANCELLED','EXPIRED','SUSPENDED') DEFAULT 'ACTIVE',
    monthly_fee DECIMAL(8,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES transport_routes(id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES transport_stops(id) ON DELETE SET NULL,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE SET NULL
);

-- =====================================================
-- LEAVE MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS leave_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    max_days_per_year INT,
    requires_approval TINYINT DEFAULT 1,
    is_carry_forward TINYINT DEFAULT 0,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS leave_balances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    total_entitled DECIMAL(5,2) DEFAULT 0,
    used_days DECIMAL(5,2) DEFAULT 0,
    carried_forward DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id) ON DELETE CASCADE,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
    UNIQUE KEY uq_leave_balance (user_id, leave_type_id, academic_year_id)
);

CREATE TABLE IF NOT EXISTS leave_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days DECIMAL(5,2) NOT NULL,
    reason TEXT NOT NULL,
    contact_during_leave VARCHAR(100),
    status ENUM('PENDING','APPROVED','REJECTED','CANCELLED','WITHDRAWN') DEFAULT 'PENDING',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_by INT,
    reviewed_at TIMESTAMP NULL,
    reviewer_remarks TEXT,
    supporting_document VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- =====================================================
-- COMMUNICATIONS & MESSAGING
-- =====================================================

CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT,
    subject VARCHAR(200),
    body TEXT NOT NULL,
    message_type ENUM('PRIVATE','GROUP','ANNOUNCEMENT','SYSTEM') DEFAULT 'PRIVATE',
    priority ENUM('LOW','NORMAL','HIGH','URGENT') DEFAULT 'NORMAL',
    is_read TINYINT DEFAULT 0,
    read_at TIMESTAMP NULL,
    parent_message_id INT,
    attachment_path VARCHAR(255),
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_message_id) REFERENCES messages(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS message_groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_by INT NOT NULL,
    is_private TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS message_group_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('ADMIN','MODERATOR','MEMBER') DEFAULT 'MEMBER',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES message_groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_group_member (group_id, user_id)
);

CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    type ENUM('INFO','SUCCESS','WARNING','ERROR','REMINDER') DEFAULT 'INFO',
    reference_type VARCHAR(50),
    reference_id INT,
    action_url VARCHAR(255),
    is_read TINYINT DEFAULT 0,
    read_at TIMESTAMP NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- DOCUMENT MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS document_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    allowed_roles VARCHAR(255),
    max_file_size_mb INT DEFAULT 10,
    allowed_extensions VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    file_path VARCHAR(255) NOT NULL,
    file_name VARCHAR(100) NOT NULL,
    file_size INT,
    mime_type VARCHAR(50),
    uploaded_by INT NOT NULL,
    visibility ENUM('PUBLIC','PRIVATE','ROLE_BASED','DEPARTMENT') DEFAULT 'PRIVATE',
    allowed_roles VARCHAR(255),
    allowed_departments VARCHAR(255),
    version INT DEFAULT 1,
    parent_document_id INT,
    is_archived TINYINT DEFAULT 0,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES document_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_document_id) REFERENCES documents(id) ON DELETE SET NULL
);

-- =====================================================
-- ACADEMIC CALENDAR & EVENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type ENUM('ACADEMIC','CULTURAL','SPORTS','SEMINAR','WORKSHOP','HOLIDAY','EXAM','MEETING','OTHER') DEFAULT 'OTHER',
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME,
    location VARCHAR(200),
    organizer_id INT,
    target_audience ENUM('ALL','STUDENTS','TEACHERS','STAFF','SPECIFIC') DEFAULT 'ALL',
    specific_roles VARCHAR(255),
    specific_departments VARCHAR(255),
    specific_courses VARCHAR(255),
    max_participants INT,
    registration_required TINYINT DEFAULT 0,
    registration_deadline DATETIME,
    is_published TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS event_registrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    user_id INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('REGISTERED','ATTENDED','ABSENT','CANCELLED','WAITLISTED') DEFAULT 'REGISTERED',
    attended_at TIMESTAMP NULL,
    feedback_rating INT,
    feedback_text TEXT,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_event_reg (event_id, user_id)
);

-- =====================================================
-- GRIEVANCE & FEEDBACK
-- =====================================================

CREATE TABLE IF NOT EXISTS grievances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    category ENUM('ACADEMIC','ADMINISTRATIVE','FACILITIES','HOSTEL','TRANSPORT','LIBRARY','HARASSMENT','DISCRIMINATION','OTHER') NOT NULL,
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('LOW','NORMAL','HIGH','URGENT') DEFAULT 'NORMAL',
    status ENUM('SUBMITTED','ACKNOWLEDGED','IN_PROGRESS','RESOLVED','CLOSED','REOPENED') DEFAULT 'SUBMITTED',
    assigned_to INT,
    resolution TEXT,
    resolved_at TIMESTAMP NULL,
    satisfaction_rating INT,
    feedback_text TEXT,
    attachment_path VARCHAR(255),
    is_anonymous TINYINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    feedback_type ENUM('COURSE','TEACHER','FACILITY','SERVICE','GENERAL') NOT NULL,
    reference_id INT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    is_anonymous TINYINT DEFAULT 0,
    status ENUM('PENDING','REVIEWED','ACTION_TAKEN') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- AUDIT & ACTIVITY LOGS
-- =====================================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    status ENUM('SUCCESS','FAILURE') DEFAULT 'SUCCESS',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_created (created_at)
);

CREATE TABLE IF NOT EXISTS activity_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(64),
    action VARCHAR(100) NOT NULL,
    page_url VARCHAR(255),
    method VARCHAR(10),
    request_params JSON,
    response_status INT,
    execution_time_ms INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_activity_user (user_id),
    INDEX idx_activity_session (session_id),
    INDEX idx_activity_created (created_at)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- ------------------------------------------------------------
-- These live in migrate_schema.sql instead of here, because a bare
-- CREATE INDEX is not idempotent: it aborts on the second run with
-- "Duplicate key name". migrate_schema.sql creates each one only if
-- it is missing, so running the pair repeatedly is safe.
-- Run order: college_db.sql  ->  migrate_schema.sql  ->  seed_demo_data.sql
-- =====================================================