-- CT6049-Assignment-002/db/operational/schema.sql
CREATE DATABASE IF NOT EXISTS library_oltp;
USE library_oltp;

-- 1. Faculty Table
CREATE TABLE IF NOT EXISTS Faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_name VARCHAR(100) NOT NULL,
    dean_name VARCHAR(100)
);

-- 2. Course Table
CREATE TABLE IF NOT EXISTS Course (
    course_code VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    faculty_id INT NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)
);

-- 3. Student Table
CREATE TABLE IF NOT EXISTS Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    course_code VARCHAR(20) NOT NULL,
    year_of_study INT,
    FOREIGN KEY (course_code) REFERENCES Course(course_code)
);

-- 4. Book Table
CREATE TABLE IF NOT EXISTS Book (
    isbn VARCHAR(20) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    shelf_location VARCHAR(50), -- e.g., "3A-102"
    publication_year INT
);

-- 5. Loan Table
CREATE TABLE IF NOT EXISTS Loan (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE, -- NULL if not returned
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (isbn) REFERENCES Book(isbn)
);

-- 6. Fine Table
CREATE TABLE IF NOT EXISTS Fine (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES Loan(loan_id)
);
