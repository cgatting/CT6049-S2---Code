-- CT6049-Assignment-002/db/warehouse/schema.sql
CREATE DATABASE IF NOT EXISTS library_dw;
USE library_dw;

-- 1. Date Dimension
CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT PRIMARY KEY, -- YYYYMMDD
    full_date DATE NOT NULL,
    day_of_month INT,
    month_name VARCHAR(20),
    month_number INT,
    quarter INT,
    year INT
);

-- 2. Student Dimension (SCD Type 1 or 2 often, simplified here to reflect current state or snapshot at load)
CREATE TABLE IF NOT EXISTS dim_student (
    student_key INT AUTO_INCREMENT PRIMARY KEY,
    student_id_oltp INT, -- Link back to OLTP
    full_name VARCHAR(100),
    course_name VARCHAR(100),
    faculty_name VARCHAR(100),
    current_year_of_study INT
);

-- 3. Book Dimension
CREATE TABLE IF NOT EXISTS dim_book (
    book_key INT AUTO_INCREMENT PRIMARY KEY,
    isbn_oltp VARCHAR(20), -- Link back to OLTP
    title VARCHAR(255),
    author VARCHAR(100),
    category VARCHAR(50),
    publication_year INT
);

-- 4. Location Dimension (Derived from Shelf Location usually, or explicit branch)
CREATE TABLE IF NOT EXISTS dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    shelf_code VARCHAR(50),
    section VARCHAR(50) -- Derived, e.g., "History", "Science"
);

-- 5. Loan Fact Table
CREATE TABLE IF NOT EXISTS fact_loan (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_date_key INT,
    due_date_key INT,
    return_date_key INT, -- Can be a special key (e.g., -1) if not returned
    student_key INT,
    book_key INT,
    location_key INT,
    
    -- Measures
    loan_count INT DEFAULT 1, -- Always 1 per row for counting
    duration_days INT,        -- DATEDIFF(return, loan)
    fine_amount DECIMAL(10, 2),
    is_overdue BOOLEAN,
    
    FOREIGN KEY (loan_date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (student_key) REFERENCES dim_student(student_key),
    FOREIGN KEY (book_key) REFERENCES dim_book(book_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key)
);

-- Indexes for Performance (Star Schema optimization)
-- MySQL Constraint: Cannot drop index needed in a foreign key constraint.
-- Foreign keys in fact_loan:
-- FOREIGN KEY (loan_date_key) REFERENCES dim_date(date_key),
-- FOREIGN KEY (student_key) REFERENCES dim_student(student_key),
-- FOREIGN KEY (book_key) REFERENCES dim_book(book_key),
-- FOREIGN KEY (location_key) REFERENCES dim_location(location_key)

-- Since we are running this script on startup, and it contains CREATE TABLE IF NOT EXISTS,
-- the tables and FKs likely already exist.
-- MySQL implicitly creates indexes for Foreign Keys.
-- So we DO NOT need to create them manually if the FK definition already created them.
-- The error "Duplicate key name" happened because we tried to create an index with a name that might already be auto-generated or explicitly created before.
-- And "Cannot drop index" happens because that index is supporting the FK.

-- SOLUTION: Just remove the explicit CREATE INDEX statements for columns that are already Foreign Keys.
-- MySQL automatically indexes FK columns. We don't need to duplicate this work.
-- If we want custom names, we should have named them in the CREATE TABLE or accepted the default.
-- For this assignment's stability, removing them is safest.

-- CREATE INDEX idx_fact_loan_date ON fact_loan(loan_date_key); -- Already indexed by FK
-- CREATE INDEX idx_fact_student ON fact_loan(student_key);     -- Already indexed by FK
-- CREATE INDEX idx_fact_book ON fact_loan(book_key);           -- Already indexed by FK
-- CREATE INDEX idx_fact_location ON fact_loan(location_key);   -- Already indexed by FK

-- Audit Table for ETL
CREATE TABLE IF NOT EXISTS etl_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    run_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50), -- SUCCESS, FAILURE
    records_processed INT,
    message TEXT
);
