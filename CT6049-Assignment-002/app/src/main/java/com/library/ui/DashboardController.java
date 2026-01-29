// CT6049-Assignment-002/app/src/main/java/com/library/ui/DashboardController.java
package com.library.ui;

import com.library.service.EtlService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
public class DashboardController {

    @Autowired
    private EtlService etlService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        model.addAttribute("username", auth.getName());
        model.addAttribute("roles", auth.getAuthorities());
        
        // Example Decision-Maker Query: Total loans by month (Trend)
        // Satisfies "Reporting DAO" requirement
        List<Map<String, Object>> reportData = getLoansByMonthReport();
        model.addAttribute("reportData", reportData);
        
        return "dashboard";
    }

    @PostMapping("/etl/run")
    public String runEtl(Model model) {
        try {
            etlService.runEtl();
            model.addAttribute("message", "ETL Process completed successfully.");
        } catch (Exception e) {
            model.addAttribute("error", "ETL Failed: " + e.getMessage());
        }
        return dashboard(model); // Reload dashboard
    }

    // Reporting Logic (DAO Pattern implemented here for simplicity)
    private List<Map<String, Object>> getLoansByMonthReport() {
        String sql = "SELECT d.month_name, d.year, SUM(f.loan_count) as total_loans " +
                     "FROM library_dw.fact_loan f " +
                     "JOIN library_dw.dim_date d ON f.loan_date_key = d.date_key " +
                     "GROUP BY d.year, d.month_number, d.month_name " +
                     "ORDER BY d.year DESC, d.month_number DESC " +
                     "LIMIT 6";
        
        return jdbcTemplate.queryForList(sql);
    }
}
