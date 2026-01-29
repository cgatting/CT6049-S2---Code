@echo off
setlocal EnableDelayedExpansion

set LOG_FILE=launch_log.txt
echo [INFO] Launch script started at %DATE% %TIME% > %LOG_FILE%

:: Function to log
call :Log "Checking environment..."

:: Check Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    call :Log "[ERROR] Java is not installed or not in PATH."
    echo Please install Java 17+ and try again.
    pause
    exit /b 1
)
call :Log "[SUCCESS] Java found."

:: Check Maven
call mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    call :Log "[ERROR] Maven is not installed or not in PATH."
    echo Please install Maven and try again.
    pause
    exit /b 1
)
call :Log "[SUCCESS] Maven found."

:: Check MySQL Port (3306)
netstat -an | find "3306" >nul
if %errorlevel% neq 0 (
    call :Log "[WARNING] MySQL port 3306 not detected. Database might be down."
    echo [WARNING] Ensure MySQL is running on port 3306.
    timeout /t 5
) else (
    call :Log "[SUCCESS] MySQL port 3306 detected."
)

:: Navigate to app directory
if not exist "app" (
    call :Log "[ERROR] 'app' directory not found."
    pause
    exit /b 1
)

pushd app

:: Build Project
call :Log "Building project with Maven..."
echo [INFO] Building project... (This may take a while)
call mvn clean install -DskipTests >> ..\%LOG_FILE% 2>&1
if %errorlevel% neq 0 (
    call :Log "[ERROR] Maven build failed. Check %LOG_FILE% for details."
    echo [ERROR] Build failed.
    popd
    pause
    exit /b 1
)
call :Log "[SUCCESS] Build successful."

:: Check JAR existence
set JAR_FILE=target\library-etl-dashboard-0.0.1-SNAPSHOT.jar
if not exist "%JAR_FILE%" (
    call :Log "[ERROR] JAR file not found at %JAR_FILE%."
    popd
    pause
    exit /b 1
)

:: Run Application
call :Log "Starting application..."
echo [INFO] Application is starting... Press Ctrl+C to stop.
echo [INFO] Access the dashboard at http://localhost:8080
java -jar "%JAR_FILE%"
if %errorlevel% neq 0 (
    call :Log "[ERROR] Application crashed."
    popd
    pause
    exit /b 1
)

popd
goto :eof

:Log
echo %~1
echo [%TIME%] %~1 >> %~dp0%LOG_FILE%
exit /b
