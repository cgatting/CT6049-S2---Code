# Project Startup Guide

## Prerequisites
Before running the application, ensure the following are installed and configured:

1.  **Java Development Kit (JDK)**: Version 17 or higher.
    - Verify with: `java -version`
2.  **Maven**: Apache Maven 3.8+.
    - Verify with: `mvn -version`
3.  **MySQL Server**: Version 8.0+.
    - Must be running on port `3306`.
    - Verify with: `netstat -an | find "3306"` (Windows Command Prompt)

## Database Setup
The application requires two database schemas: `library_oltp` and `library_dw`.

1.  **Operational Database (`library_oltp`)**:
    - Run the script: `db/operational/schema.sql`
2.  **Data Warehouse (`library_dw`)**:
    - Run the script: `db/warehouse/schema.sql`

Ensure the database user configured in `app/src/main/resources/application.properties` (default: `root`/`password`) has permissions to access both schemas.

## Automated Launch
Use the provided batch file `lunch.bat` to automatically check the environment, build the project, and start the application.

1.  Double-click `lunch.bat` or run it from the command line:
    ```cmd
    .\lunch.bat
    ```
2.  The script will:
    - Validate Java, Maven, and MySQL availability.
    - Build the application using Maven.
    - Start the Spring Boot application.
    - Log detailed output to `launch_log.txt`.

## Manual Startup
If you prefer to run manually:

1.  Navigate to the `app` directory:
    ```cmd
    cd app
    ```
2.  Build the project:
    ```cmd
    mvn clean install
    ```
3.  Run the JAR file:
    ```cmd
    java -jar target/library-etl-dashboard-0.0.1-SNAPSHOT.jar
    ```

## Troubleshooting
- **Database Connection Error**: Ensure MySQL is running and the credentials in `application.properties` are correct.
- **Build Failure**: Check `launch_log.txt` or run `mvn clean install` manually to see error details.
- **Port Conflict**: Ensure port `8080` is free. Change `server.port` in `application.properties` if needed.
