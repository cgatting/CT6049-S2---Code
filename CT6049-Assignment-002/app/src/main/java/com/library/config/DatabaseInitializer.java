package com.library.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.datasource.init.ScriptUtils;

import javax.sql.DataSource;
import java.io.File;
import java.sql.Connection;

@Configuration
public class DatabaseInitializer {

    @Autowired
    private DataSource dataSource;

    @Bean
    public CommandLineRunner initDatabase() {
        return args -> {
            System.out.println("Initializing Database Schemas...");

            // Determine paths to SQL files (relative to 'app' directory where jar runs)
            File operationalSchema = new File("../db/operational/schema.sql");
            File operationalData = new File("../db/operational/data.sql");
            File warehouseSchema = new File("../db/warehouse/schema.sql");

            if (operationalSchema.exists() && warehouseSchema.exists()) {
                try (Connection conn = dataSource.getConnection()) {
                    // Run Operational Schema
                    System.out.println("Executing " + operationalSchema.getPath());
                    ScriptUtils.executeSqlScript(conn, new FileSystemResource(operationalSchema));
                    
                    // Run Operational Data Seeding (if exists)
                    if (operationalData.exists()) {
                        System.out.println("Executing " + operationalData.getPath());
                        try {
                            ScriptUtils.executeSqlScript(conn, new FileSystemResource(operationalData));
                        } catch (Exception e) {
                             System.out.println("Data seeding skipped (Data might already exist or error): " + e.getMessage());
                        }
                    }

                    // Run Warehouse Schema
                    System.out.println("Executing " + warehouseSchema.getPath());
                    ScriptUtils.executeSqlScript(conn, new FileSystemResource(warehouseSchema));
                    
                    System.out.println("Database initialization completed successfully.");
                } catch (Exception e) {
                    System.err.println("Error initializing database: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                System.err.println("Schema files not found. Expected at: " + operationalSchema.getAbsolutePath());
                System.err.println("Skipping database initialization.");
            }
        };
    }
}
