-- =====================================================================
-- Mangaud CollegeHub - Demo / Test Data Seed
-- ---------------------------------------------------------------------
-- Idempotent: safe to run repeatedly. Uses INSERT ... ON DUPLICATE KEY
-- UPDATE for reference tables and re-uses lookups by natural key so no
-- duplicate rows are created on a second run.
--
-- Passwords are real bcrypt (cost 12) hashes, matching the application's
-- DBUtil.verifyPassword(). See DEMO_CREDENTIALS at the bottom.
-- =====================================================================

USE college_db;

-- ---------------------------------------------------------------------
-- Reset demo data before seeding.
--
-- A seed file is not transactional, so a failure part-way through would
-- otherwise leave earlier rows committed and the next run would collide on
-- a natural key. Clearing first makes this file safely re-runnable.
--
-- Only demo data is removed; the schema is untouched.
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE activity_logs;
TRUNCATE TABLE feedback;
TRUNCATE TABLE events;
TRUNCATE TABLE event_registrations;
TRUNCATE TABLE grievances;
TRUNCATE TABLE notifications;
TRUNCATE TABLE messages;
TRUNCATE TABLE leave_balances;
TRUNCATE TABLE leave_requests;
TRUNCATE TABLE leave_types;
TRUNCATE TABLE transport_bookings;
TRUNCATE TABLE transport_stops;
TRUNCATE TABLE transport_routes;
TRUNCATE TABLE transport_vehicles;
TRUNCATE TABLE hostel_visitors;
TRUNCATE TABLE hostel_allocations;
TRUNCATE TABLE hostel_rooms;
TRUNCATE TABLE hostels;
TRUNCATE TABLE library_reservations;
TRUNCATE TABLE library_issues;
TRUNCATE TABLE library_members;
TRUNCATE TABLE library_books;
TRUNCATE TABLE library_categories;
TRUNCATE TABLE scholarship_applications;
TRUNCATE TABLE scholarships;
TRUNCATE TABLE fee_payments;
TRUNCATE TABLE fee_structures;
TRUNCATE TABLE exam_results;
TRUNCATE TABLE exams;
TRUNCATE TABLE timetable;
TRUNCATE TABLE timetable_slots;
TRUNCATE TABLE semesters;
TRUNCATE TABLE academic_years;
TRUNCATE TABLE notices;
TRUNCATE TABLE marks;
TRUNCATE TABLE attendance;
TRUNCATE TABLE enrollments;
TRUNCATE TABLE courses;
TRUNCATE TABLE programs;
TRUNCATE TABLE departments;
TRUNCATE TABLE student_documents;
TRUNCATE TABLE student_profiles;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;
SET @now = NOW();

-- ---------------------------------------------------------------------
-- USERS
-- ---------------------------------------------------------------------
INSERT INTO users (username,email,password_hash,salt,role,full_name,phone,gender,dob,address,active) VALUES
 ('admin','admin@mangaud.edu','$2a$12$yKt0RW2G1y6kSADNu9HphOLmEQpxjsjMM.4aTVEYxNHvQiXIZsl9a','','ADMIN','System Administrator','+91-90000-00001','Male','1985-04-12','Main Campus, Mangaud',1),
 ('viceprincipal','vp@mangaud.edu','$2a$12$SNqieBMo4WihYFfaqQL6zO/VZmeYJ6LR3vtNvNHX06kC8YC6j/sZ6','','ADMIN','Dr. Anita Deshmukh','+91-90000-00002','Female','1978-11-03','Admin Block, Mangaud',1),
 ('teacher1','teacher1@mangaud.edu','$2a$12$24rWnbrJHIT8NzkCBoDrxORD1T32Rns0Awgp9adumrX3Toxmv0YpK','','TEACHER','Prof. Rajesh Menon','+91-90000-10001','Male','1982-07-21','CSE Block, Mangaud',1),
 ('teacher2','teacher2@mangaud.edu','$2a$12$dym4cbbfeSZ1Ut4RCs4vyOLEvJDPLV7tu0FJRIeEH7VMw9kWLDr9m','','TEACHER','Dr. Sneha Kulkarni','+91-90000-10002','Female','1986-02-15','CSE Block, Mangaud',1),
 ('teacher3','teacher3@mangaud.edu','$2a$12$Bz6BSe8iiPOwAxs/s4WghOC4dJIjf6GTuaRtg3SbK0mspgf8g6.ui','','TEACHER','Prof. Vikram Iyer','+91-90000-10003','Male','1979-09-30','ECE Block, Mangaud',1),
 ('teacher4','teacher4@mangaud.edu','$2a$12$h3a.A5RfgY1TdjSJ87aGd.d2EdJSb9TATAoAO7BysHo/AWKvf88Vi','','TEACHER','Dr. Priya Nair','+91-90000-10004','Female','1984-05-18','Mechanical Block, Mangaud',1),
 ('student1','student1@mangaud.edu','$2a$12$j6TjbP1BYvu2fzpT4vYpQ.HeCoqE9tlpNfvFHfnUm9ZtA1iBa3JFO','','STUDENT','Aarav Sharma','+91-90000-20001','Male','2005-03-10','Hostel A, Mangaud',1),
 ('student2','student2@mangaud.edu','$2a$12$Kur2gT/bjZ9ngR4p2wXlY.EVO6ZxdQQuHwnKDHLCvFJQtJ27xjRWe','','STUDENT','Diya Patel','+91-90000-20002','Female','2006-01-22','Hostel B, Mangaud',1),
 ('student3','student3@mangaud.edu','$2a$12$j9C1pogLw4ic5TCplwu8G.bOk.u4VGCmNk/NpuA8m1rx7fR34vosi','','STUDENT','Kabir Singh','+91-90000-20003','Male','2004-12-05','Day Scholar',1),
 ('student4','student4@mangaud.edu','$2a$12$lVW1E/e7mZUjP.k/Mz70y.j2VrrBmWMp3T6KxbUG1PeCuikz8rYrW','','STUDENT','Ishita Rao','+91-90000-20004','Female','2005-08-19','Hostel B, Mangaud',1),
 ('student5','student5@mangaud.edu','$2a$12$tYnf65c5xwQl5OtrGWQ2TOtuF3wb6HXJwXb3XwKBkK/fcVH9gTAkW','','STUDENT','Rohan Verma','+91-90000-20005','Male','2006-06-14','Day Scholar',1),
 ('student6','student6@mangaud.edu','$2a$12$GG6w.lajiH7rZLvr2p9WS.ijv1ojCl.b8JEE3.2BPRLfV7S91/FiS','','STUDENT','Ananya Gupta','+91-90000-20006','Female','2005-10-27','Hostel A, Mangaud',1),
 ('student7','student7@mangaud.edu','$2a$12$PE2SwEgapvNTidKWnuhVgeK8Jb.xwokcXDNidATNZiCTfr/ttA9h2','','STUDENT','Arjun Mehta','+91-90000-20007','Male','2006-02-08','Day Scholar',1),
 ('student8','student8@mangaud.edu','$2a$12$KlPQ7nTXOsrEejYmYocIBOJBVG22VyKrexGMrWXqu549TVe8QSIAe','','STUDENT','Meera Joshi','+91-90000-20008','Female','2004-11-30','Hostel A, Mangaud',1),
 ('parent1','parent1@mangaud.edu','$2a$12$VryyREiwgtEaWGutAbOs6OR7oS4zg9IXihdkWAY8b5nliy6AOGODO','','PARENT','Suresh Sharma','+91-90000-30001','Male','1980-01-01','Mumbai',1),
 ('accountant','accounts@mangaud.edu','$2a$12$j7csDtIg9WU7EDygsqx1Q.pEDJ4k9IiHqAkc5VdA6iKLAJVldbEo2','','ACCOUNTANT','Neha Agarwal','+91-90000-40001','Female','1988-07-09','Accounts Section',1),
 ('librarian','library@mangaud.edu','$2a$12$WosKQE2h9wEelhu/HqoEnurVqXPjThZfxLBzcApqG9N585hyQXil.','','LIBRARIAN','Suresh Kumar','+91-90000-40002','Male','1983-04-25','Library Block',1),
 ('warden','warden@mangaud.edu','$2a$12$vQ4Y2YXnfAXF.Ver/1CqOuYAz4tVm4yY981CvgmJ.OCDtQQLnMFUe','','HOSTEL_WARDEN','Kavita Reddy','+91-90000-40003','Female','1975-12-02','Hostel A',1),
 ('transport','transport@mangaud.edu','$2a$12$Ikkv1oshik8jkKh9JZ1l2uEtWLzs22JR8XZmkhQZjOugiJ4i90Sm2','','TRANSPORT_MANAGER','Devendra Patil','+91-90000-40004','Male','1976-06-17','Transport Depot',1)
ON DUPLICATE KEY UPDATE
  password_hash = VALUES(password_hash),
  role         = VALUES(role),
  full_name    = VALUES(full_name),
  phone        = VALUES(phone),
  active       = 1;

-- ---------------------------------------------------------------------
-- DEPARTMENTS
-- ---------------------------------------------------------------------
INSERT INTO departments (name,code,hod_id,description) VALUES
 ('Computer Science & Engineering','CSE',  (SELECT id FROM users WHERE username='teacher1'),'Algorithms, systems and software engineering.'),
 ('Electronics & Communication','ECE',       (SELECT id FROM users WHERE username='teacher3'),'Signal processing, embedded systems and communication.'),
 ('Mechanical Engineering','MECH',         (SELECT id FROM users WHERE username='teacher4'),'Thermodynamics, manufacturing and design.'),
 ('Basic Sciences & Humanities','BSH',     (SELECT id FROM users WHERE username='teacher2'),'Mathematics, physics, chemistry and communication skills.')
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);

-- ---------------------------------------------------------------------
-- PROGRAMS
-- ---------------------------------------------------------------------
INSERT INTO programs (code,name,department_id,duration_years,total_semesters,eligibility_criteria) VALUES
 ('BTECH','Bachelor of Technology',        (SELECT id FROM departments WHERE code='CSE'),  4,8,'10+2 with Physics, Chemistry and Mathematics, 50% aggregate'),
 ('BCA', 'Bachelor of Computer Applications',(SELECT id FROM departments WHERE code='CSE'),3,6,'10+2 with Mathematics, 45% aggregate'),
 ('B.Tech-ECE','Bachelor of Technology (ECE)',(SELECT id FROM departments WHERE code='ECE'),4,8,'10+2 with Physics, Chemistry and Mathematics, 55% aggregate'),
 ('BME','Bachelor of Mechanical Engineering',(SELECT id FROM departments WHERE code='MECH'),4,8,'10+2 with Physics, Chemistry and Mathematics, 50% aggregate')
ON DUPLICATE KEY UPDATE name=VALUES(name), eligibility_criteria=VALUES(eligibility_criteria);

-- ---------------------------------------------------------------------
-- COURSES
-- ---------------------------------------------------------------------
INSERT INTO courses (code,title,description,credits,semester,program_id,department_id,teacher_id,max_students) VALUES
 ('CS201','Data Structures & Algorithms','Arrays, lists, trees, graphs and complexity analysis.',4,3,(SELECT id FROM programs WHERE code='BCA'),(SELECT id FROM departments WHERE code='CSE'),(SELECT id FROM users WHERE username='teacher1'),60),
 ('CS202','Database Management Systems','Relational modelling, SQL and normalisation.',4,3,(SELECT id FROM programs WHERE code='BCA'),(SELECT id FROM departments WHERE code='CSE'),(SELECT id FROM users WHERE username='teacher1'),60),
 ('CS203','Object Oriented Programming','Classes, inheritance, polymorphism in Java.',4,3,(SELECT id FROM programs WHERE code='BCA'),(SELECT id FROM departments WHERE code='CSE'),(SELECT id FROM users WHERE username='teacher2'),60),
 ('CS204','Computer Networks','TCP/IP, routing and network security fundamentals.',3,4,(SELECT id FROM programs WHERE code='BCA'),(SELECT id FROM departments WHERE code='CSE'),(SELECT id FROM users WHERE username='teacher2'),60),
 ('EC101','Digital Signal Processing','Sampling, convolution and filter design.',4,5,(SELECT id FROM programs WHERE code='B.Tech-ECE'),(SELECT id FROM departments WHERE code='ECE'),(SELECT id FROM users WHERE username='teacher3'),55),
 ('ME101','Thermodynamics','Laws, cycles and power plant analysis.',4,5,(SELECT id FROM programs WHERE code='BME'),(SELECT id FROM departments WHERE code='MECH'),(SELECT id FROM users WHERE username='teacher4'),50),
 ('HS101','Engineering Mathematics I','Matrices, calculus and series.',4,1,(SELECT id FROM programs WHERE code='BTECH'),(SELECT id FROM departments WHERE code='BSH'),(SELECT id FROM users WHERE username='teacher2'),70)
ON DUPLICATE KEY UPDATE title=VALUES(title), description=VALUES(description), credits=VALUES(credits);

-- ---------------------------------------------------------------------
-- ACADEMIC CALENDAR
-- ---------------------------------------------------------------------
INSERT INTO academic_years (name,start_date,end_date,is_current,is_active) VALUES
 ('2025-26','2025-06-01','2026-05-31',0,1),
 ('2026-27','2026-06-01','2027-05-31',1,1)
ON DUPLICATE KEY UPDATE is_current=VALUES(is_current), is_active=VALUES(is_active);

INSERT INTO semesters (academic_year_id,name,number,start_date,end_date,registration_start,registration_end,exam_start,exam_end,is_current,is_active) VALUES
 ((SELECT id FROM academic_years WHERE name='2026-27'),'Semester 1',1,'2026-06-01','2026-11-30','2026-06-01','2026-07-15','2026-11-20','2026-11-30',1,1),
 ((SELECT id FROM academic_years WHERE name='2026-27'),'Semester 2',2,'2026-12-01','2027-05-31','2026-12-01','2027-01-15','2027-05-15','2027-05-31',0,1),
 ((SELECT id FROM academic_years WHERE name='2025-26'),'Semester 1',1,'2025-06-01','2025-11-30','2025-06-01','2025-07-15','2025-11-20','2025-11-30',0,1)
ON DUPLICATE KEY UPDATE start_date=VALUES(start_date), end_date=VALUES(end_date), is_current=VALUES(is_current);

INSERT INTO timetable_slots (name,start_time,end_time,day_of_week,slot_order,is_break) VALUES
 ('Period 1','09:00:00','09:55:00','MONDAY',1,0),
 ('Period 2','10:00:00','10:55:00','MONDAY',2,0),
 ('Period 3','11:15:00','12:10:00','MONDAY',3,0),
 ('Lunch Break','12:10:00','13:00:00','MONDAY',4,1),
 ('Period 4','13:00:00','13:55:00','MONDAY',5,0)
ON DUPLICATE KEY UPDATE start_time=VALUES(start_time), end_time=VALUES(end_time);

-- ---------------------------------------------------------------------
-- ENROLLMENTS  (every student in two courses)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO enrollments (student_id,course_id,status) VALUES
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS203'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS204'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM courses WHERE code='CS202'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM courses WHERE code='CS203'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS202'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS201'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student5'),(SELECT id FROM courses WHERE code='CS203'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student5'),(SELECT id FROM courses WHERE code='CS202'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student6'),(SELECT id FROM courses WHERE code='CS204'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student7'),(SELECT id FROM courses WHERE code='CS201'),'ENROLLED'),
 ((SELECT id FROM users WHERE username='student8'),(SELECT id FROM courses WHERE code='CS202'),'ENROLLED');

-- ---------------------------------------------------------------------
-- ATTENDANCE  (recent, varied so the average is meaningful)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO attendance (student_id,course_id,att_date,status,marked_by) VALUES
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 4 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 3 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 2 DAY,'ABSENT', (SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 1 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),CURDATE()            ,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 4 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 3 DAY,'LATE',   (SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 2 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 1 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),CURDATE()            ,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM courses WHERE code='CS202'),CURDATE() - INTERVAL 4 DAY,'ABSENT', (SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM courses WHERE code='CS202'),CURDATE() - INTERVAL 3 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 4 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 3 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 2 DAY,'EXCUSED',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student5'),(SELECT id FROM courses WHERE code='CS203'),CURDATE() - INTERVAL 4 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student5'),(SELECT id FROM courses WHERE code='CS203'),CURDATE() - INTERVAL 3 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student6'),(SELECT id FROM courses WHERE code='CS204'),CURDATE() - INTERVAL 4 DAY,'ABSENT', (SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student6'),(SELECT id FROM courses WHERE code='CS204'),CURDATE() - INTERVAL 3 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student7'),(SELECT id FROM courses WHERE code='CS201'),CURDATE() - INTERVAL 4 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student8'),(SELECT id FROM courses WHERE code='CS202'),CURDATE() - INTERVAL 4 DAY,'PRESENT',(SELECT id FROM users WHERE username='teacher1'));

-- ---------------------------------------------------------------------
-- MARKS
-- ---------------------------------------------------------------------
INSERT IGNORE INTO marks (student_id,course_id,exam_type,marks_obtained,max_marks,entered_by) VALUES
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),'INTERNAL',78,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS201'),'MIDTERM',  82,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM courses WHERE code='CS203'),'INTERNAL',71,100,(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),'INTERNAL',85,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM courses WHERE code='CS201'),'MIDTERM',  88,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM courses WHERE code='CS202'),'INTERNAL',64,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS201'),'INTERNAL',90,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student4'),(SELECT id FROM courses WHERE code='CS201'),'MIDTERM',  93,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student5'),(SELECT id FROM courses WHERE code='CS203'),'INTERNAL',58,100,(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student6'),(SELECT id FROM courses WHERE code='CS204'),'INTERNAL',76,100,(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM users WHERE username='student7'),(SELECT id FROM courses WHERE code='CS201'),'INTERNAL',69,100,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM users WHERE username='student8'),(SELECT id FROM courses WHERE code='CS202'),'INTERNAL',81,100,(SELECT id FROM users WHERE username='teacher1'));

-- ---------------------------------------------------------------------
-- NOTICES
-- ---------------------------------------------------------------------
INSERT INTO notices (title,body,posted_by,audience,priority,published_at,is_pinned) VALUES
 ('Mid-Semester Examination Timetable Released','The mid-semester examination schedule for Semesters 1 and 2 is now available in the Academic module. Examinations begin on 2026-11-20.',(SELECT id FROM users WHERE username='admin'),'ALL','HIGH',NOW(),1),
 ('Library Extended Hours During Exams','The central library will remain open until 22:00 during the examination period. Students must return or renew borrowed books before their due dates.',(SELECT id FROM users WHERE username='librarian'),'STUDENT','NORMAL',NOW(),0),
 ('Annual Sports Day - Registrations Open','Registrations for the annual inter-departmental sports day are open. Team events require a faculty coordinator. Register via the Events module.',(SELECT id FROM users WHERE username='admin'),'ALL','NORMAL',NOW(),0),
 ('Hostel Maintenance Notice','Water supply maintenance is scheduled in Hostel A on Saturday between 09:00 and 13:00. Residents are advised to plan accordingly.',(SELECT id FROM users WHERE username='warden'),'STUDENT','LOW',NOW(),0),
 ('Fee Payment Deadline Reminder','The last date to pay semester fees without a late fee is approaching. Payments can be made online or at the accounts office.',(SELECT id FROM users WHERE username='accountant'),'STUDENT','URGENT',NOW(),1)
ON DUPLICATE KEY UPDATE body=VALUES(body), priority=VALUES(priority);

-- ---------------------------------------------------------------------
-- EXAMS + RESULTS
-- ---------------------------------------------------------------------
INSERT INTO exams (name,exam_type,course_id,semester_id,exam_date,start_time,end_time,room,building,max_marks,passing_marks,instructions,status,created_by) VALUES
 ('CS201 Mid-Term','MIDTERM',(SELECT id FROM courses WHERE code='CS201'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),'2026-11-20','10:00:00','12:00:00','A-101','CSE Block',100,40,'Answer all questions. Calculators are not permitted.','COMPLETED',(SELECT id FROM users WHERE username='teacher1')),
 ('CS203 Mid-Term','MIDTERM',(SELECT id FROM courses WHERE code='CS203'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),'2026-11-21','10:00:00','12:00:00','A-102','CSE Block',100,40,'Answer all questions.','SCHEDULED',(SELECT id FROM users WHERE username='teacher2')),
 ('CS202 Mid-Term','MIDTERM',(SELECT id FROM courses WHERE code='CS202'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),'2026-11-22','10:00:00','12:00:00','A-103','CSE Block',100,40,'Answer all questions.','SCHEDULED',(SELECT id FROM users WHERE username='teacher1'))
ON DUPLICATE KEY UPDATE status=VALUES(status), exam_date=VALUES(exam_date);

INSERT IGNORE INTO exam_results (exam_id,student_id,marks_obtained,status,graded_by,remarks) VALUES
 ((SELECT id FROM exams WHERE name='CS201 Mid-Term'),(SELECT id FROM users WHERE username='student1'),82,'APPEARED',(SELECT id FROM users WHERE username='teacher1'),'Good grasp of graph algorithms.'),
 ((SELECT id FROM exams WHERE name='CS201 Mid-Term'),(SELECT id FROM users WHERE username='student2'),88,'APPEARED',(SELECT id FROM users WHERE username='teacher1'),'Excellent.'),
 ((SELECT id FROM exams WHERE name='CS201 Mid-Term'),(SELECT id FROM users WHERE username='student4'),93,'APPEARED',(SELECT id FROM users WHERE username='teacher1'),'Outstanding performance.'),
 ((SELECT id FROM exams WHERE name='CS201 Mid-Term'),(SELECT id FROM users WHERE username='student7'),55,'APPEARED',(SELECT id FROM users WHERE username='teacher1'),'Needs practice on dynamic programming.');

-- ---------------------------------------------------------------------
-- TIMETABLE ENTRIES
-- ---------------------------------------------------------------------
-- day_of_week / start_time / end_time live on the slot, not on the entry.
INSERT INTO timetable (course_id,semester_id,slot_id,room,building,effective_from,effective_to,is_recurring,created_by) VALUES
 ((SELECT id FROM courses WHERE code='CS201'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),(SELECT id FROM timetable_slots WHERE name='Period 1'),'A-101','CSE Block','2026-06-01','2027-05-31',1,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM courses WHERE code='CS201'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),(SELECT id FROM timetable_slots WHERE name='Period 3'),'A-101','CSE Block','2026-06-01','2027-05-31',1,(SELECT id FROM users WHERE username='teacher1')),
 ((SELECT id FROM courses WHERE code='CS203'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),(SELECT id FROM timetable_slots WHERE name='Period 2'),'A-102','CSE Block','2026-06-01','2027-05-31',1,(SELECT id FROM users WHERE username='teacher2')),
 ((SELECT id FROM courses WHERE code='CS202'),(SELECT id FROM semesters WHERE number=1 AND academic_year_id=(SELECT id FROM academic_years WHERE name='2026-27')),(SELECT id FROM timetable_slots WHERE name='Period 4'),'A-103','CSE Block','2026-06-01','2027-05-31',1,(SELECT id FROM users WHERE username='teacher1'));

-- ---------------------------------------------------------------------
-- FEES
-- ---------------------------------------------------------------------
INSERT INTO fee_structures (name,program_id,semester,category,academic_year_id,tuition_fee,lab_fee,library_fee,sports_fee,exam_fee,development_fee,hostel_fee,transport_fee,misc_fee,due_date,late_fee_per_day,max_late_fee,is_active) VALUES
 ('BCA Sem 1 - General',(SELECT id FROM programs WHERE code='BCA'),1,'GENERAL',(SELECT id FROM academic_years WHERE name='2026-27'),45000,6000,3000,2000,2500,5000,0,0,1500,'2026-08-15',25,500,1),
 ('BCA Sem 1 - OBC',(SELECT id FROM programs WHERE code='BCA'),1,'OBC',(SELECT id FROM academic_years WHERE name='2026-27'),40000,6000,3000,2000,2500,5000,0,0,1500,'2026-08-15',25,500,1),
 ('B.Tech Sem 1 - General',(SELECT id FROM programs WHERE code='BTECH'),1,'GENERAL',(SELECT id FROM academic_years WHERE name='2026-27'),85000,12000,4000,3000,3500,8000,0,0,2000,'2026-08-15',50,1000,1)
ON DUPLICATE KEY UPDATE tuition_fee=VALUES(tuition_fee), is_active=1;

INSERT INTO fee_payments (student_id,fee_structure_id,amount_paid,payment_mode,transaction_ref,receipt_number,received_by,status,late_fee,discount) VALUES
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM fee_structures WHERE name='BCA Sem 1 - General'),50000,'UPI','UPI24081101','RCPT-0001',(SELECT id FROM users WHERE username='accountant'),'COMPLETED',0,0),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM fee_structures WHERE name='BCA Sem 1 - OBC'),45000,'CARD','CARD8812','RCPT-0002',(SELECT id FROM users WHERE username='accountant'),'COMPLETED',0,0),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM fee_structures WHERE name='BCA Sem 1 - General'),30000,'NEFT','NEFT9921','RCPT-0003',(SELECT id FROM users WHERE username='accountant'),'PARTIAL',0,0);

-- ---------------------------------------------------------------------
-- SCHOLARSHIPS
-- ---------------------------------------------------------------------
INSERT INTO scholarships (name,code,description,eligibility_criteria,amount_type,amount_value,max_recipients,academic_year_id,application_start,application_end) VALUES
 ('Merit Scholarship','MERIT','Awarded to students in the top 5% of their programme.','Top 5% aggregate in the previous examination.',  'PERCENTAGE',50,20,(SELECT id FROM academic_years WHERE name='2026-27'),'2026-07-01','2026-09-30'),
 ('Means-cum-Merit Aid','MEANS','Financial assistance for students from economically weaker sections.','Family income below 2.5 lakh per annum.',            'FIXED',25000,30,(SELECT id FROM academic_years WHERE name='2026-27'),'2026-07-01','2026-10-15'),
 ('Sports Achievement Award','SPORTS','For state and national level sportspersons.','Representation at state or national level.',          'FIXED',25000,10,(SELECT id FROM academic_years WHERE name='2026-27'),'2026-07-01','2026-11-30')
ON DUPLICATE KEY UPDATE description=VALUES(description), amount_value=VALUES(amount_value);

-- ---------------------------------------------------------------------
-- LIBRARY
-- ---------------------------------------------------------------------
INSERT INTO library_categories (name,code,description) VALUES
 ('Computer Science','CS','Programming, algorithms and computing textbooks.'),
 ('Engineering','ENG','Core engineering references and handbooks.'),
 ('General Reference','GEN','Fiction, biography and general interest.'),
 ('Competitive Programming','CP','Algorithms, puzzles and interview preparation.')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO library_books (isbn,title,author,publisher,edition,publication_year,category_id,total_copies,available_copies,location_rack,location_shelf,price,language,pages,description,status) VALUES
 ('9780132350884','Introduction to Algorithms','Thomas H. Cormen, Charles E. Leiserson','MIT Press','3rd',2009,(SELECT id FROM library_categories WHERE code='CP'),5,4,'R1','S3',950,'English',1312,'The definitive algorithms reference.','AVAILABLE'),
 ('9780134685991','The Pragmatic Programmer','Andrew Hunt, David Thomas','Addison-Wesley','20th',2019,(SELECT id FROM library_categories WHERE code='CS'),4,3,'R1','S1',750,'English',352,'A classic on software craftsmanship.','AVAILABLE'),
 ('9780321125217','Domain-Driven Design','Eric Evans','Addison-Wesley','1st',2003,(SELECT id FROM library_categories WHERE code='CS'),3,2,'R1','S2',800,'English',560,'Strategic design for software.','AVAILABLE'),
 ('9780321127426','Patterns of Enterprise Application Architecture','Martin Fowler','Addison-Wesley','1st',2002,(SELECT id FROM library_categories WHERE code='CS'),3,3,'R1','S2',720,'English',640,'Enterprise architecture patterns.','AVAILABLE'),
 ('9787115546081','Clean Code','Robert C. Martin','Prentice Hall','1st',2008,(SELECT id FROM library_categories WHERE code='CS'),4,2,'R2','S1',680,'English',464,'Writing maintainable code.','AVAILABLE'),
 ('9780135957059','The Pragmatic Programmer (20th Anniversary Ed.)','Andrew Hunt, David Thomas','Addison-Wesley','20th',2019,(SELECT id FROM library_categories WHERE code='CS'),2,2,'R2','S1',750,'English',352,'Annotated edition.','AVAILABLE'),
 ('9780262033848','Introduction to Algorithms (Large Print)','Cormen et al.','MIT Press','3rd',2009,(SELECT id FROM library_categories WHERE code='CP'),2,1,'R1','S4',1050,'English',1312,'Large print edition.','ISSUED'),
 ('9780198611860','Sapiens: A Brief History of Humankind','Yuval Noah Harari','Harper','1st',2011,(SELECT id FROM library_categories WHERE code='GEN'),3,3,'R3','S1',600,'English',498,'A sweeping history of humankind.','AVAILABLE'),
 ('9780062316097','Sapiens (Illustrated)','Yuval Noah Harari','Harper','1st',2015,(SELECT id FROM library_categories WHERE code='GEN'),2,2,'R3','S2',750,'English',443,'Illustrated edition.','AVAILABLE'),
 ('9780062315007','Atomic Habits','James Clear','Penguin','1st',2018,(SELECT id FROM library_categories WHERE code='GEN'),3,3,'R3','S3',450,'English',320,'Habits and behaviour change.','AVAILABLE')
ON DUPLICATE KEY UPDATE available_copies=VALUES(available_copies), status=VALUES(status);

-- Library members: every student and teacher gets a card.
INSERT INTO library_members (user_id,member_type,membership_number,join_date,expiry_date,max_books_allowed,max_issue_days,fine_per_day,max_fine,is_active)
SELECT u.id, u.role, CONCAT('LIB-', LPAD(u.id,5,'0')), '2026-06-01', '2027-05-31',
       CASE WHEN u.role='TEACHER' THEN 6 ELSE 3 END, 14, 5.00, 500.00, 1
FROM users u WHERE u.role IN ('STUDENT','TEACHER')
ON DUPLICATE KEY UPDATE is_active=1;

-- Current loans (decrement the catalogue accordingly).
INSERT INTO library_issues (book_id,member_id,issue_date,due_date,renewed_count,max_renewals,fine_amount,issued_by,status) VALUES
 ((SELECT id FROM library_books WHERE isbn='9780262033848'),(SELECT lm.id FROM library_members lm JOIN users u ON u.id=lm.user_id WHERE u.username='student1'),CURDATE() - INTERVAL 20 DAY,CURDATE() - INTERVAL 6 DAY,0,2,30.00,(SELECT id FROM users WHERE username='librarian'),'OVERDUE'),
 ((SELECT id FROM library_books WHERE isbn='9780134685991'),(SELECT lm.id FROM library_members lm JOIN users u ON u.id=lm.user_id WHERE u.username='student2'),CURDATE() - INTERVAL 5 DAY,CURDATE() + INTERVAL 9 DAY,0,2,0,(SELECT id FROM users WHERE username='librarian'),'ISSUED'),
 ((SELECT id FROM library_books WHERE isbn='9780321125217'),(SELECT lm.id FROM library_members lm JOIN users u ON u.id=lm.user_id WHERE u.username='student3'),CURDATE() - INTERVAL 3 DAY,CURDATE() + INTERVAL 11 DAY,1,2,0,(SELECT id FROM users WHERE username='librarian'),'ISSUED'),
 ((SELECT id FROM library_books WHERE isbn='9787115546081'),(SELECT lm.id FROM library_members lm JOIN users u ON u.id=lm.user_id WHERE u.username='teacher1'),CURDATE() - INTERVAL 7 DAY,CURDATE() + INTERVAL 7 DAY,0,2,0,(SELECT id FROM users WHERE username='librarian'),'ISSUED');

-- ---------------------------------------------------------------------
-- HOSTELS
-- ---------------------------------------------------------------------
INSERT INTO hostels (name,code,type,warden_id,address,total_rooms,total_beds,facilities,rules,contact_phone,contact_email,is_active) VALUES
 ('Nilgiri Boys Hostel','HB-A','BOYS',(SELECT id FROM users WHERE username='warden'),'North Campus, Mangaud',20,80,'Wi-Fi, Laundry, Gym, Mess, Study Hall','No visitors after 8 PM. Lights off at 10:30 PM.','+91-90000-50001','hb-a@mangaud.edu',1),
 ('Saarangi Girls Hostel','HB-B','GIRLS',(SELECT id FROM users WHERE username='warden'),'South Campus, Mangaud',16,64,'Wi-Fi, Laundry, Gym, Mess, Study Hall','No visitors after 8 PM. Lights off at 10:30 PM.','+91-90000-50002','hb-b@mangaud.edu',1)
ON DUPLICATE KEY UPDATE total_rooms=VALUES(total_rooms), total_beds=VALUES(total_beds);

INSERT INTO hostel_rooms (hostel_id,room_number,floor,room_type,capacity,occupied_beds,rent_per_month,has_ac,has_attached_bathroom,furniture_details,status) VALUES
 ((SELECT id FROM hostels WHERE code='HB-A'),'101',1,'DOUBLE',2,2,6000,0,1,'Bed, Study table, Wardrobe','OCCUPIED'),
 ((SELECT id FROM hostels WHERE code='HB-A'),'102',1,'DOUBLE',2,1,6000,0,1,'Bed, Study table, Wardrobe','PARTIAL'),
 ((SELECT id FROM hostels WHERE code='HB-A'),'103',1,'SINGLE',1,0,8000,1,1,'Bed, Study table, Wardrobe','AVAILABLE'),
 ((SELECT id FROM hostels WHERE code='HB-A'),'104',1,'TRIPLE',3,3,5000,0,0,'Three beds, Two study tables','OCCUPIED'),
 ((SELECT id FROM hostels WHERE code='HB-A'),'201',2,'DOUBLE',2,0,6200,0,1,'Bed, Study table, Wardrobe','AVAILABLE'),
 ((SELECT id FROM hostels WHERE code='HB-B'),'201',1,'DOUBLE',2,2,6500,0,1,'Bed, Study table, Wardrobe','OCCUPIED'),
 ((SELECT id FROM hostels WHERE code='HB-B'),'202',1,'DOUBLE',2,1,6500,0,1,'Bed, Study table, Wardrobe','PARTIAL'),
 ((SELECT id FROM hostels WHERE code='HB-B'),'203',1,'SINGLE',1,0,8500,1,1,'Bed, Study table, Wardrobe','AVAILABLE')
ON DUPLICATE KEY UPDATE occupied_beds=VALUES(occupied_beds), status=VALUES(status);

-- Room allocations
INSERT INTO hostel_allocations (student_id,room_id,bed_number,allocated_by,allocated_date,academic_year_id,status) VALUES
 ((SELECT id FROM users WHERE username='student1'),(SELECT r.id FROM hostel_rooms r JOIN hostels h ON h.id=r.hostel_id WHERE h.code='HB-A' AND r.room_number='101'),1,(SELECT id FROM users WHERE username='warden'),CURDATE(),(SELECT id FROM academic_years WHERE name='2026-27'),'ACTIVE'),
 ((SELECT id FROM users WHERE username='student2'),(SELECT r.id FROM hostel_rooms r JOIN hostels h ON h.id=r.hostel_id WHERE h.code='HB-B' AND r.room_number='201'),1,(SELECT id FROM users WHERE username='warden'),CURDATE(),(SELECT id FROM academic_years WHERE name='2026-27'),'ACTIVE'),
 ((SELECT id FROM users WHERE username='student4'),(SELECT r.id FROM hostel_rooms r JOIN hostels h ON h.id=r.hostel_id WHERE h.code='HB-B' AND r.room_number='201'),2,(SELECT id FROM users WHERE username='warden'),CURDATE(),(SELECT id FROM academic_years WHERE name='2026-27'),'ACTIVE')
ON DUPLICATE KEY UPDATE bed_number=VALUES(bed_number), status='ACTIVE';

-- ---------------------------------------------------------------------
-- TRANSPORT
-- ---------------------------------------------------------------------
INSERT INTO transport_vehicles (vehicle_number,vehicle_type,capacity,model,manufacturer,registration_date,fuel_type,status) VALUES
 ('MH-12-AB-1234','BUS',52,'Tata Starbus','Tata','2022-03-15','DIESEL','ACTIVE'),
 ('MH-12-AB-5678','BUS',52,'Tata Starbus','Tata','2022-07-20','DIESEL','ACTIVE'),
 ('MH-12-AC-9012','VAN',26,'Force Traveller','Force Motors','2021-11-02','DIESEL','ACTIVE')
ON DUPLICATE KEY UPDATE status='ACTIVE';

INSERT INTO transport_routes (name,code,description,start_point,end_point,distance_km,estimated_time_minutes,monthly_fee,driver_id,conductor_id,vehicle_id,is_active) VALUES
 ('Campus to Hinjewadi','R-01','Morning pickup from campus, evening drop at Hinjewadi IT Park.','Mangaud Campus','Hinjewadi Phase 2',28,55,1200,(SELECT id FROM users WHERE username='transport'),NULL,(SELECT id FROM transport_vehicles WHERE vehicle_number='MH-12-AB-1234'),1),
 ('Campus to Kothrud','R-02','Via Karve Road, serves western residential belt.','Mangaud Campus','Kothrud',18,40,900,(SELECT id FROM users WHERE username='transport'),NULL,(SELECT id FROM transport_vehicles WHERE vehicle_number='MH-12-AB-5678'),1),
 ('Campus to Hadapsar','R-03','Serves eastern IT and industrial corridor.','Mangaud Campus','Hadapsar',32,60,1400,(SELECT id FROM users WHERE username='transport'),NULL,(SELECT id FROM transport_vehicles WHERE vehicle_number='MH-12-AC-9012'),1)
ON DUPLICATE KEY UPDATE is_active=1;

INSERT INTO transport_stops (route_id,stop_name,stop_order,latitude,longitude,arrival_time,departure_time,is_pickup,is_drop) VALUES
 ((SELECT id FROM transport_routes WHERE code='R-01'),'Mangaud Campus',1,18.5204,73.8567,'07:15:00','07:20:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-01'),'Kothrud Depot',2,18.5074,73.8077,'07:45:00','07:50:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-01'),'Baner Road',3,18.5642,73.7769,'08:10:00','08:15:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-01'),'Hinjewadi Phase 2',4,18.5913,73.7389,'08:40:00',NULL,0,1),
 ((SELECT id FROM transport_routes WHERE code='R-02'),'Mangaud Campus',1,18.5204,73.8567,'07:00:00','07:05:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-02'),'Karve Road',2,18.4983,73.8077,'07:25:00','07:30:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-02'),'Kothrud',3,18.5074,73.8077,'07:45:00',NULL,0,1),
 ((SELECT id FROM transport_routes WHERE code='R-03'),'Mangaud Campus',1,18.5204,73.8567,'07:00:00','07:05:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-03'),'Kothrud',2,18.5074,73.8077,'07:40:00','07:45:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-03'),'Wagholi',3,18.5800,73.9800,'08:20:00','08:25:00',1,0),
 ((SELECT id FROM transport_routes WHERE code='R-03'),'Hadapsar',4,18.5089,73.9260,'08:50:00',NULL,0,1);

-- ---------------------------------------------------------------------
-- LEAVE
-- ---------------------------------------------------------------------
INSERT INTO leave_types (name,code,description,max_days_per_year,requires_approval,is_carry_forward,is_active) VALUES
 ('Casual Leave','CL','Short-term personal absence.',12,1,0,1),
 ('Sick Leave','SL','Illness and medical appointments.',12,1,0,1),
 ('Earned Leave','EL','Accrued leave for longer absence.',20,1,1,1),
 ('Sports Leave','SP','Representing the college in competitions.',10,1,0,1),
 ('On-Duty Leave','OD','Official college work outside campus.',15,1,0,1)
ON DUPLICATE KEY UPDATE description=VALUES(description), is_active=1;

INSERT INTO leave_requests (user_id,leave_type_id,start_date,end_date,total_days,reason,contact_during_leave,status,applied_at,reviewed_by,reviewed_at,reviewer_remarks) VALUES
 ((SELECT id FROM users WHERE username='student1'),(SELECT id FROM leave_types WHERE code='CL'),CURDATE() - INTERVAL 10 DAY,CURDATE() - INTERVAL 9 DAY,2,'Family function at home.','+91-90000-20001','APPROVED',NOW() - INTERVAL 15 DAY,(SELECT id FROM users WHERE username='teacher1'),NOW() - INTERVAL 14 DAY,'Approved. Please submit the assignment.'),
 ((SELECT id FROM users WHERE username='student2'),(SELECT id FROM leave_types WHERE code='SL'),CURDATE() - INTERVAL 5 DAY,CURDATE() - INTERVAL 3 DAY,3,'Viral fever, advised rest by a doctor.','+91-90000-20002','APPROVED',NOW() - INTERVAL 6 DAY,(SELECT id FROM users WHERE username='teacher2'),NOW() - INTERVAL 6 DAY,'Get well soon.'),
 ((SELECT id FROM users WHERE username='student3'),(SELECT id FROM leave_types WHERE code='CL'),CURDATE() + INTERVAL 7 DAY,CURDATE() + INTERVAL 8 DAY,2,'Sibling wedding.','+91-90000-20003','PENDING',NOW(),NULL,NULL,NULL),
 ((SELECT id FROM users WHERE username='teacher1'),(SELECT id FROM leave_types WHERE code='EL'),CURDATE() + INTERVAL 20 DAY,CURDATE() + INTERVAL 22 DAY,3,'Family vacation.','+91-90000-10001','PENDING',NOW(),NULL,NULL,NULL);

-- ---------------------------------------------------------------------
-- MESSAGES + NOTIFICATIONS
-- ---------------------------------------------------------------------
INSERT INTO messages (sender_id,recipient_id,subject,body,message_type,priority,is_read,read_at,sent_at) VALUES
 ((SELECT id FROM users WHERE username='admin'),(SELECT id FROM users WHERE username='student1'),'Welcome to Mangaud CollegeHub','Welcome to the college portal. Your student account is active. Please complete your profile and verify your documents.','ANNOUNCEMENT','NORMAL',1,NOW() - INTERVAL 2 DAY,NOW() - INTERVAL 2 DAY),
 ((SELECT id FROM users WHERE username='teacher1'),(SELECT id FROM users WHERE username='student1'),'CS201 Assignment 1 Grades','Your Assignment 1 has been graded. You scored 78/100. Keep up the good work.','PRIVATE','NORMAL',0,NULL,NOW() - INTERVAL 1 DAY),
 ((SELECT id FROM users WHERE username='teacher1'),(SELECT id FROM users WHERE username='student2'),'CS201 Attendance Reminder','You have missed two classes this week. Please make sure you attend regularly.','PRIVATE','HIGH',0,NULL,NOW() - INTERVAL 1 DAY),
 ((SELECT id FROM users WHERE username='librarian'),(SELECT id FROM users WHERE username='student3'),'Book Overdue','Your borrowed book is overdue. Please return it or renew it to avoid further fines.','SYSTEM','HIGH',0,NULL,NOW()),
 ((SELECT id FROM users WHERE username='accountant'),(SELECT id FROM users WHERE username='student3'),'Fee Payment Pending','Your semester fee is partially paid. Please clear the balance before the due date.','SYSTEM','NORMAL',0,NULL,NOW());

INSERT INTO notifications (user_id,title,body,type,is_read,read_at,sent_at) VALUES
 ((SELECT id FROM users WHERE username='student1'),'Fee Receipt Generated','Your fee payment receipt RCPT-0001 has been generated.','SUCCESS',0,NULL,NOW()),
 ((SELECT id FROM users WHERE username='student1'),'Mid-Semester Examination Timetable Released','The mid-semester examination schedule is now available in the Academic module.','INFO',0,NULL,NOW()),
 ((SELECT id FROM users WHERE username='student2'),'Library Extended Hours During Exams','The central library will remain open until 22:00 during the examination period.','INFO',1,NOW() - INTERVAL 1 DAY,NOW() - INTERVAL 1 DAY),
 ((SELECT id FROM users WHERE username='student3'),'Book Overdue','Your borrowed book is overdue by 6 days.','WARNING',0,NULL,NOW()),
 ((SELECT id FROM users WHERE username='teacher1'),'New Leave Request','A new leave request is pending your approval.','REMINDER',0,NULL,NOW());

-- ---------------------------------------------------------------------
-- EVENTS
-- ---------------------------------------------------------------------
INSERT INTO events (title,description,event_type,start_datetime,end_datetime,location,organizer_id,target_audience,is_published,max_participants,registration_required,registration_deadline) VALUES
 ('Annual Sports Day','Inter-departmental athletics and team sports. Come cheer for your programme.','SPORTS',NOW() + INTERVAL 30 DAY,NOW() + INTERVAL 31 DAY,'Main Ground',(SELECT id FROM users WHERE username='admin'),'ALL',1,0,0,NULL),
 ('TechTalk: AI in Practice','A guest lecture on applied machine learning delivered by an industry practitioner.','SEMINAR',NOW() + INTERVAL 12 DAY,NOW() + INTERVAL 12 DAY + INTERVAL 2 HOUR,'Seminar Hall A',(SELECT id FROM users WHERE username='teacher1'),'ALL',1,120,1,NOW() + INTERVAL 10 DAY),
 ('Hackathon Mangaud','24-hour build sprint. Open to all programmes. Prizes for best product and best design.','WORKSHOP',NOW() + INTERVAL 20 DAY,NOW() + INTERVAL 21 DAY,'Computing Lab',(SELECT id FROM users WHERE username='teacher2'),'ALL',1,60,1,NOW() + INTERVAL 15 DAY),
 ('Ganesh Chaturthi Holiday','The college will remain closed. Regular classes resume afterwards.','HOLIDAY',NOW() + INTERVAL 40 DAY,NOW() + INTERVAL 40 DAY + INTERVAL 8 HOUR,'-',(SELECT id FROM users WHERE username='admin'),'ALL',1,0,0,NULL),
 ('Parent-Teacher Meeting','Programme-wise PTM. Slot booking at the front office.','MEETING',NOW() + INTERVAL 25 DAY,NOW() + INTERVAL 25 DAY + INTERVAL 4 HOUR,'Auditorium',(SELECT id FROM users WHERE username='admin'),'ALL',1,0,0,NULL);

INSERT INTO event_registrations (event_id,user_id,status) VALUES
 ((SELECT id FROM events WHERE title='TechTalk: AI in Practice'),(SELECT id FROM users WHERE username='student1'),'REGISTERED'),
 ((SELECT id FROM events WHERE title='TechTalk: AI in Practice'),(SELECT id FROM users WHERE username='student2'),'REGISTERED'),
 ((SELECT id FROM events WHERE title='Hackathon Mangaud'),(SELECT id FROM users WHERE username='student1'),'REGISTERED'),
 ((SELECT id FROM events WHERE title='Hackathon Mangaud'),(SELECT id FROM users WHERE username='student5'),'REGISTERED');

-- ---------------------------------------------------------------------
-- GRIEVANCES
-- ---------------------------------------------------------------------
INSERT INTO grievances (student_id,category,subject,description,priority,status,assigned_to,is_anonymous,created_at) VALUES
 ((SELECT id FROM users WHERE username='student1'),'FACILITIES','Classroom projector not working','The projector in Room A-101 has not been working for two weeks. Lectures are difficult to follow.','NORMAL','IN_PROGRESS',(SELECT id FROM users WHERE username='viceprincipal'),0,NOW() - INTERVAL 10 DAY),
 ((SELECT id FROM users WHERE username='student2'),'LIBRARY','Requested title not available','The second edition of the requested algorithms textbook is not in the library. It has been pending for three weeks.','LOW','SUBMITTED',NULL,0,NOW() - INTERVAL 5 DAY),
 ((SELECT id FROM users WHERE username='student3'),'TRANSPORT','Route R-01 runs late every morning','The bus consistently departs 10-15 minutes behind schedule, causing students to miss the first period.','HIGH','ACKNOWLEDGED',(SELECT id FROM users WHERE username='transport'),0,NOW() - INTERVAL 3 DAY),
 ((SELECT id FROM users WHERE username='student4'),'ADMINISTRATIVE','Degree certificate correction request','A typo in the name printed on my provisional certificate needs to be corrected before convocation.','HIGH','RESOLVED',(SELECT id FROM users WHERE username='viceprincipal'),0,NOW() - INTERVAL 30 DAY),
 ((SELECT id FROM users WHERE username='student5'),'ACADEMIC','Lab sessions moved without notice','The DBMS lab sessions were rescheduled to a non-lab slot at short notice, disrupting the practical work.','NORMAL','ACKNOWLEDGED',(SELECT id FROM users WHERE username='viceprincipal'),1,NOW() - INTERVAL 2 DAY);

-- ---------------------------------------------------------------------
-- LEAVE BALANCES
-- ---------------------------------------------------------------------
INSERT INTO leave_balances (user_id,leave_type_id,academic_year_id,total_entitled,used_days,carried_forward)
SELECT u.id, lt.id, (SELECT id FROM academic_years WHERE name='2026-27'), lt.max_days_per_year,
       COALESCE((SELECT SUM(lr.total_days) FROM leave_requests lr WHERE lr.user_id=u.id AND lr.leave_type_id=lt.id AND lr.status='APPROVED'),0),
       0
FROM users u CROSS JOIN leave_types lt
WHERE u.role IN ('STUDENT','TEACHER')
ON DUPLICATE KEY UPDATE used_days=VALUES(used_days), total_entitled=VALUES(total_entitled);

-- ---------------------------------------------------------------------
-- STUDENT PROFILES  (the fee module resolves the applicable fee via this)
-- ---------------------------------------------------------------------
INSERT INTO student_profiles (user_id,student_id,program_id,current_semester,admission_date,admission_type,category,religion,blood_group,father_name,father_occupation,father_phone,mother_name,mother_occupation,mother_phone,emergency_contact_name,emergency_contact_phone,emergency_contact_relation,is_hostel_resident,hostel_id,room_number,transport_required,transport_route_id,annual_income)
VALUES
 ((SELECT id FROM users WHERE username='student1'),'MGD2026CSE001',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','GENERAL','Hindu','B+','Rakesh Sharma','Engineer','+91-98200-10001','Sunita Sharma','Homemaker','+91-98200-10002','Rakesh Sharma','+91-98200-10001','Father',1,(SELECT id FROM hostels WHERE code='HB-A'),'101',0,NULL,900000),
 ((SELECT id FROM users WHERE username='student2'),'MGD2026CSE002',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','OBC','Hindu','O+','Mahesh Patel','Business','+91-98200-10003','Kavita Patel','Teacher','+91-98200-10004','Mahesh Patel','+91-98200-10003','Father',1,(SELECT id FROM hostels WHERE code='HB-B'),'201',0,NULL,420000),
 ((SELECT id FROM users WHERE username='student3'),'MGD2026CSE003',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','GENERAL','Sikh','A+','Harjit Singh','Farmer','+91-98200-10005','Baljeet Kaur','Homemaker','+91-98200-10006','Harjit Singh','+91-98200-10005','Father',0,NULL,NULL,1,(SELECT id FROM transport_routes WHERE code='R-01'),280000),
 ((SELECT id FROM users WHERE username='student4'),'MGD2026CSE004',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','SC','Hindu','AB+','Ganesh Rao','Government Job','+91-98200-10007','Lakshmi Rao','Government Job','+91-98200-10008','Ganesh Rao','+91-98200-10007','Father',1,(SELECT id FROM hostels WHERE code='HB-B'),'201',0,NULL,510000),
 ((SELECT id FROM users WHERE username='student5'),'MGD2026CSE005',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','GENERAL','Hindu','B-','Sanjay Verma','Engineer','+91-98200-10009','Anita Verma','Doctor','+91-98200-10010','Sanjay Verma','+91-98200-10009','Father',0,NULL,NULL,0,NULL,1200000),
 ((SELECT id FROM users WHERE username='student6'),'MGD2026CSE006',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','EWS','Hindu','O-','Alok Gupta','Shopkeeper','+91-98200-10011','Pooja Gupta','Homemaker','+91-98200-10012','Alok Gupta','+91-98200-10011','Father',1,(SELECT id FROM hostels WHERE code='HB-A'),'104',0,NULL,240000),
 ((SELECT id FROM users WHERE username='student7'),'MGD2026CSE007',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','GENERAL','Hindu','AB-','Nitin Mehta','Manager','+91-98200-10013','Renu Mehta','Homemaker','+91-98200-10014','Nitin Mehta','+91-98200-10013','Father',0,NULL,NULL,1,(SELECT id FROM transport_routes WHERE code='R-03'),760000),
 ((SELECT id FROM users WHERE username='student8'),'MGD2026CSE008',(SELECT id FROM programs WHERE code='BCA'),1,'2026-06-15','REGULAR','OBC','Hindu','A+','Prakash Joshi','Farmer','+91-98200-10015','Surekha Joshi','Homemaker','+91-98200-10016','Prakash Joshi','+91-98200-10015','Father',1,(SELECT id FROM hostels WHERE code='HB-A'),'101',0,NULL,310000)
ON DUPLICATE KEY UPDATE current_semester=VALUES(current_semester), category=VALUES(category);

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- DEMO_CREDENTIALS  (all passwords are real bcrypt, cost 12)
-- =====================================================================
-- admin        / Admin@123       System Administrator
-- viceprincipal/ Vice@123       Vice Principal (ADMIN role)
-- teacher1..4  / Teacher@123    Faculty
-- student1..8  / Student@123    Students
-- parent1      / Parent@123     Parent
-- accountant   / Accounts@123   Fees
-- librarian    / Library@123    Library
-- warden       / Warden@123     Hostel
-- transport    / Transport@123  Transport
