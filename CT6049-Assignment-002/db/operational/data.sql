-- CT6049-Assignment-002/db/operational/data.sql
USE library_oltp;

-- 1. Faculty
INSERT INTO Faculty (faculty_name, dean_name) VALUES 
('Faculty of Science', 'Dr. Alice Smith'),
('Faculty of Arts', 'Prof. Bob Jones'),
('Faculty of Engineering', 'Dr. Charlie Brown');

-- 2. Course
INSERT INTO Course (course_code, course_name, faculty_id) VALUES 
('CS101', 'Computer Science', 1),
('ENG202', 'Mechanical Engineering', 3),
('ART303', 'History of Art', 2),
('PHY101', 'Physics', 1);

-- 3. Student
INSERT INTO Student (first_name, last_name, email, course_code, year_of_study) VALUES 
('John', 'Doe', 'john.doe@uni.edu', 'CS101', 1),
('Jane', 'Roe', 'jane.roe@uni.edu', 'ENG202', 2),
('Jim', 'Beam', 'jim.beam@uni.edu', 'ART303', 3),
('Jack', 'Daniels', 'jack.daniels@uni.edu', 'CS101', 4);

-- 4. Book
INSERT INTO Book (isbn, title, author, category, shelf_location, publication_year) VALUES 
('978-3-16-148410-0', 'Introduction to Algorithms', 'Thomas H. Cormen', 'Textbook', 'A1-101', 2009),
('978-0-13-235088-4', 'Clean Code', 'Robert C. Martin', 'Technology', 'A1-102', 2008),
('978-0-321-35668-0', 'Effective Java', 'Joshua Bloch', 'Technology', 'A1-103', 2018),
('978-0-19-855910-1', 'The Art of War', 'Sun Tzu', 'History', 'B2-201', 2005),
('978-0-7432-7356-5', 'The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 'C3-301', 1925);

-- 5. Loan (Dates tailored to show trend)
-- Past loans (Returned)
INSERT INTO Loan (student_id, isbn, loan_date, due_date, return_date) VALUES 
(1, '978-3-16-148410-0', DATE_SUB(CURDATE(), INTERVAL 3 MONTH), DATE_SUB(CURDATE(), INTERVAL 2 MONTH), DATE_SUB(CURDATE(), INTERVAL 2 MONTH)),
(2, '978-0-13-235088-4', DATE_SUB(CURDATE(), INTERVAL 3 MONTH), DATE_SUB(CURDATE(), INTERVAL 2 MONTH), DATE_SUB(CURDATE(), INTERVAL 80 DAY)), -- Late
(3, '978-0-19-855910-1', DATE_SUB(CURDATE(), INTERVAL 2 MONTH), DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_SUB(CURDATE(), INTERVAL 1 MONTH)),
(1, '978-0-321-35668-0', DATE_SUB(CURDATE(), INTERVAL 1 MONTH), CURDATE(), DATE_SUB(CURDATE(), INTERVAL 2 DAY));

-- Active loans (Not returned)
INSERT INTO Loan (student_id, isbn, loan_date, due_date, return_date) VALUES 
(4, '978-0-7432-7356-5', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), NULL),
(2, '978-3-16-148410-0', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);

-- 6. Fine
INSERT INTO Fine (loan_id, amount, paid) VALUES 
(2, 5.50, TRUE); -- Fine for the late book
