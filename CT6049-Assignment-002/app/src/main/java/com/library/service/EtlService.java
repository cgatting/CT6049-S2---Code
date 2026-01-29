// CT6049-Assignment-002/app/src/main/java/com/library/service/EtlService.java
package com.library.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
public class EtlService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Transactional
    public void runEtl() {
        long startTime = System.currentTimeMillis();
        int recordsProcessed = 0;
        String status = "SUCCESS";
        StringBuilder message = new StringBuilder("ETL Started. ");

        try {
            // 1. Load Date Dimension (simplified: ensure current year dates exist)
            // Ideally this is pre-populated, but we'll add today if missing
            loadDateDimension();
            message.append("Dates checked. ");

            // 2. Load Dimensions (SCD Type 1 - Overwrite/Ignore)
            
            // Dim Student
            String sqlStudent = "INSERT INTO library_dw.dim_student (student_id_oltp, full_name, course_name, faculty_name, current_year_of_study) " +
                                "SELECT s.student_id, CONCAT(s.first_name, ' ', s.last_name), c.course_name, f.faculty_name, s.year_of_study " +
                                "FROM library_oltp.Student s " +
                                "JOIN library_oltp.Course c ON s.course_code = c.course_code " +
                                "JOIN library_oltp.Faculty f ON c.faculty_id = f.faculty_id " +
                                "WHERE s.student_id NOT IN (SELECT student_id_oltp FROM library_dw.dim_student WHERE student_id_oltp IS NOT NULL)";

            int students = jdbcTemplate.update(sqlStudent);
            message.append("Students: ").append(students).append(". ");

            // Dim Book
            int books = jdbcTemplate.update(
                "INSERT INTO library_dw.dim_book (isbn_oltp, title, author, category, publication_year) " +
                "SELECT isbn, title, author, category, publication_year " +
                "FROM library_oltp.Book " +
                "WHERE isbn NOT IN (SELECT isbn_oltp FROM library_dw.dim_book WHERE isbn_oltp IS NOT NULL)"
            );
            message.append("Books: ").append(books).append(". ");

            // Dim Location
            // Extract distinct locations from Books
            int locations = jdbcTemplate.update(
                "INSERT INTO library_dw.dim_location (shelf_code, section) " +
                "SELECT DISTINCT shelf_location, 'General' " +
                "FROM library_oltp.Book " +
                "WHERE shelf_location NOT IN (SELECT shelf_code FROM library_dw.dim_location WHERE shelf_code IS NOT NULL)"
            );
            message.append("Locations: ").append(locations).append(". ");

            // 3. Load Fact Table
            // Transform: Lookup keys from dimensions based on OLTP IDs
            String factSql = 
                "INSERT INTO library_dw.fact_loan (loan_date_key, due_date_key, return_date_key, student_key, book_key, location_key, loan_count, duration_days, fine_amount, is_overdue) " +
                "SELECT " +
                "   CAST(DATE_FORMAT(l.loan_date, '%Y%m%d') AS UNSIGNED), " +
                "   CAST(DATE_FORMAT(l.due_date, '%Y%m%d') AS UNSIGNED), " +
                "   IF(l.return_date IS NULL, NULL, CAST(DATE_FORMAT(l.return_date, '%Y%m%d') AS UNSIGNED)), " +
                "   ds.student_key, " +
                "   db.book_key, " +
                "   dl.location_key, " +
                "   1, " +
                "   IF(l.return_date IS NULL, NULL, DATEDIFF(l.return_date, l.loan_date)), " +
                "   (SELECT SUM(amount) FROM library_oltp.Fine f WHERE f.loan_id = l.loan_id), " +
                "   IF(l.return_date > l.due_date OR (l.return_date IS NULL AND CURRENT_DATE > l.due_date), TRUE, FALSE) " +
                "FROM library_oltp.Loan l " +
                "JOIN library_oltp.Student s ON l.student_id = s.student_id " +
                "JOIN library_dw.dim_student ds ON s.student_id = ds.student_id_oltp " +
                "JOIN library_oltp.Book b ON l.isbn = b.isbn " +
                "JOIN library_dw.dim_book db ON b.isbn = db.isbn_oltp " +
                "JOIN library_dw.dim_location dl ON b.shelf_location = dl.shelf_code " +
                "WHERE 1=1"; // Full reload strategy for simplicity
            
            // Clear facts for full reload
            jdbcTemplate.execute("DELETE FROM library_dw.fact_loan");
            int facts = jdbcTemplate.update(factSql);
            message.append("Facts: ").append(facts).append(". ");
            recordsProcessed = facts;

        } catch (Exception e) {
            status = "FAILURE";
            message.append("Error: ").append(e.getMessage());
            e.printStackTrace();
        } finally {
            logRun(status, recordsProcessed, message.toString());
        }
    }

    private void loadDateDimension() {
        // Ensure today exists
        LocalDate today = LocalDate.now();
        int dateKey = Integer.parseInt(today.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        
        String checkSql = "SELECT count(*) FROM library_dw.dim_date WHERE date_key = ?";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, dateKey);
        
        if (count != null && count == 0) {
            String insertSql = "INSERT INTO library_dw.dim_date (date_key, full_date, day_of_month, month_name, month_number, quarter, year) VALUES (?, ?, ?, ?, ?, ?, ?)";
            jdbcTemplate.update(insertSql, 
                dateKey, 
                today, 
                today.getDayOfMonth(), 
                today.getMonth().name(), 
                today.getMonthValue(), 
                (today.getMonthValue() - 1) / 3 + 1, 
                today.getYear()
            );
        }
    }

    private void logRun(String status, int records, String msg) {
        String sql = "INSERT INTO library_dw.etl_log (status, records_processed, message) VALUES (?, ?, ?)";
        jdbcTemplate.update(sql, status, records, msg);
    }
}
