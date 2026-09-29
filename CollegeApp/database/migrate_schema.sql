-- =====================================================================
-- Mangaud CollegeHub - Schema Migration
-- ---------------------------------------------------------------------
-- Closes the gap between the original 7-table / 3-role prototype database
-- and the 48-table production schema shipped in college_db.sql.
--
-- Fully idempotent: uses add_index_if_missing / add_key_if_missing helper
-- procedures, so running this file any number of times is a no-op after the
-- first success. No DROP, no data loss.
--
-- Run order:
--   1. college_db.sql        (creates the 48 tables)
--   2. migrate_schema.sql    (widens the role enum, adds natural keys)
--   3. seed_demo_data.sql    (demo users and data)
-- =====================================================================

USE college_db;

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_key_if_missing;

DELIMITER $$

-- Adds a UNIQUE index only when it is not already defined.
CREATE PROCEDURE add_index_if_missing(IN p_table VARCHAR(64), IN p_index VARCHAR(64), IN p_cols VARCHAR(512))
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND INDEX_NAME = p_index
  ) THEN
    SET @sql := CONCAT('ALTER TABLE `', p_table, '` ADD UNIQUE KEY `', p_index, '` (', p_cols, ')');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
  END IF;
END$$

-- Adds a non-unique index only when it is not already defined.
CREATE PROCEDURE add_key_if_missing(IN p_table VARCHAR(64), IN p_index VARCHAR(64), IN p_cols VARCHAR(512))
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND INDEX_NAME = p_index
  ) THEN
    SET @sql := CONCAT('ALTER TABLE `', p_table, '` ADD KEY `', p_index, '` (', p_cols, ')');
    PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
  END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- 1. Widen the role enum to the full 8-role model the application uses.
--    The prototype schema allowed only ADMIN / TEACHER / STUDENT, which
--    made it impossible to create an ACCOUNTANT, LIBRARIAN,
--    HOSTEL_WARDEN, TRANSPORT_MANAGER or PARENT account at all.
-- ---------------------------------------------------------------------
ALTER TABLE users
  MODIFY COLUMN role ENUM('ADMIN','TEACHER','STUDENT','PARENT','LIBRARIAN',
                         'ACCOUNTANT','HOSTEL_WARDEN','TRANSPORT_MANAGER')
  NOT NULL;

-- ---------------------------------------------------------------------
-- 2. Natural keys.
--    INSERT ... ON DUPLICATE KEY UPDATE needs something to collide on.
--    Without these the demo seed silently duplicates rows on every re-run.
-- ---------------------------------------------------------------------
CALL add_index_if_missing('timetable_slots',     'uq_slot',            'name, day_of_week, start_time');
CALL add_index_if_missing('timetable',           'uq_tt',              'course_id, semester_id, slot_id');
CALL add_index_if_missing('exams',               'uq_exam',            'name, course_id, semester_id');
CALL add_index_if_missing('notices',             'uq_notice',          'title, posted_by');
CALL add_index_if_missing('transport_stops',     'uq_route_stop',      'route_id, stop_order');
CALL add_index_if_missing('transport_routes',    'uq_route_code',      'code, is_active');
CALL add_index_if_missing('leave_requests',      'uq_user_leave',      'user_id, leave_type_id, start_date');
CALL add_index_if_missing('library_issues',      'uq_issue',           'book_id, member_id, issue_date');
CALL add_index_if_missing('hostel_allocations',  'uq_alloc',           'student_id, room_id, allocated_date');
CALL add_index_if_missing('grievances',          'uq_grievance',       'student_id, subject');
CALL add_index_if_missing('library_categories',  'uq_libcat_code',     'code');
CALL add_index_if_missing('leave_types',         'uq_leave_type_code', 'code');
CALL add_index_if_missing('scholarships',        'uq_scholarship_code','code');
CALL add_index_if_missing('hostels',             'uq_hostel_code',     'code');
CALL add_index_if_missing('student_profiles',    'uq_student_roll',    'student_id');

-- ---------------------------------------------------------------------
-- 3. Read-path indexes.
--    Every dashboard issues several COUNT/SELECT queries; without these
--    the list screens fall back to full scans as the tables grow.
-- ---------------------------------------------------------------------
CALL add_key_if_missing('users',             'idx_users_role',        'role');
CALL add_key_if_missing('users',             'idx_users_active_role', 'active, role');
CALL add_key_if_missing('courses',           'idx_courses_teacher',   'teacher_id');
CALL add_key_if_missing('courses',           'idx_courses_dept',      'department_id');
CALL add_key_if_missing('enrollments',       'idx_enroll_course',     'course_id');
CALL add_key_if_missing('attendance',        'idx_att_course_date',   'course_id, att_date');
CALL add_key_if_missing('marks',             'idx_mark_course',       'course_id');
CALL add_key_if_missing('fee_payments',      'idx_fee_pay_student',   'student_id');
CALL add_key_if_missing('fee_payments',      'idx_fee_pay_structure', 'fee_structure_id');
CALL add_key_if_missing('library_issues',    'idx_issue_member',      'member_id');
CALL add_key_if_missing('library_issues',    'idx_issue_status',      'status');
CALL add_key_if_missing('leave_requests',    'idx_leave_user_status', 'user_id, status');
CALL add_key_if_missing('messages',          'idx_msg_recipient',     'recipient_id, is_read');
CALL add_key_if_missing('notifications',     'idx_notif_user',        'user_id, is_read');
CALL add_key_if_missing('exam_results',      'idx_result_exam',       'exam_id');
CALL add_key_if_missing('hostel_rooms',      'idx_room_hostel',       'hostel_id');
CALL add_key_if_missing('transport_stops',   'idx_stop_route',        'route_id');
CALL add_key_if_missing('event_registrations','idx_reg_event',         'event_id');

-- The original performance index set, kept here because a bare
-- CREATE INDEX is not idempotent and would abort on a second run.
CALL add_key_if_missing('users',                 'idx_users_active',           'active');
CALL add_key_if_missing('enrollments',           'idx_enrollments_student',    'student_id');
CALL add_key_if_missing('attendance',            'idx_attendance_date',        'att_date');
CALL add_key_if_missing('marks',                 'idx_marks_exam_type',        'exam_type');
CALL add_key_if_missing('notices',               'idx_notices_audience',       'audience');
CALL add_key_if_missing('notices',               'idx_notices_published',      'published_at');
CALL add_key_if_missing('library_issues',        'idx_library_issues_book',    'book_id');
CALL add_key_if_missing('transport_bookings',    'idx_transport_bookings_student','student_id');
CALL add_key_if_missing('leave_requests',        'idx_leave_requests_user',    'user_id');
CALL add_key_if_missing('messages',              'idx_messages_recipient',     'recipient_id');
CALL add_key_if_missing('notifications',         'idx_notifications_user',     'user_id');
CALL add_key_if_missing('grievances',            'idx_grievances_status',      'status');

-- ---------------------------------------------------------------------
-- 4. Notes
-- ---------------------------------------------------------------------
-- exam_results stores marks_obtained only. The percentage and max marks
-- shown in the UI are derived by AcademicDAO by joining the parent exam,
-- so no column is required here.
--
-- hostel_rooms.available_beds is likewise derived (capacity - occupied)
-- by the HostelRoom model rather than stored, to avoid drift.

DROP PROCEDURE IF EXISTS add_index_if_missing;
DROP PROCEDURE IF EXISTS add_key_if_missing;
