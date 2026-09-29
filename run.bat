@echo off
setlocal enabledelayedexpansion
REM ============================================================================
REM  Mangaud CollegeHub  -  One-Click Local Deploy for Windows
REM ----------------------------------------------------------------------------
REM  Double-click this file, or run:  run.bat
REM
REM  It will, in order:
REM    1. Locate a JDK
REM    2. Start MySQL if it is installed but stopped
REM    3. Create the database, apply the schema + migration, load demo data
REM    4. Build CollegeApp.war with Maven
REM    5. Deploy to Tomcat and start it
REM    6. Wait until the app reports healthy
REM    7. Open your browser at the local URL
REM
REM  No Docker. No manual steps.
REM ============================================================================

title Mangaud CollegeHub - Local Deploy

REM ---- Everything is resolved relative to this script, so it works from any CWD
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
cd /d "%ROOT%"

set "APP_DIR=%ROOT%\CollegeApp"
set "TOMCAT_DIR=%ROOT%\apache-tomcat-10.1"
set "MAVEN_DIR=%ROOT%\maven\apache-maven-3.9.9"
set "WAR_NAME=CollegeApp"
set "CONTEXT=/CollegeApp"
set "PORT=8080"
set "URL=http://localhost:%PORT%%CONTEXT%/"

set "DB_NAME=college_db"
set "DB_USER=root"
set "DB_PASS=system"

echo.
echo  ==========================================================================
echo    M A N G A U D   C O L L E G E H U B
echo    Local deployment
echo  ==========================================================================
echo.

REM ---------------------------------------------------------------------------
REM  STEP 1 - JDK
REM ---------------------------------------------------------------------------
echo [1/7] Locating a JDK...

set "JAVA_HOME="
REM Prefer a modern JDK; the project targets Java 11 and runs on 17/21/25.
for %%D in ("%ProgramFiles%\Java\jdk-25" "%ProgramFiles%\Java\jdk-21" "%ProgramFiles%\Java\jdk-17" "%ProgramFiles%\Eclipse Adoptium") do (
    if not defined JAVA_HOME (
        if exist "%%~D\bin\javac.exe" (
            if exist "%%~D\bin\java.exe" set "JAVA_HOME=%%~D"
        )
    )
)
REM Adoptium folder is versioned, so probe it one level down.
if not defined JAVA_HOME if exist "%ProgramFiles%\Eclipse Adoptium" (
    for /d %%V in ("%ProgramFiles%\Eclipse Adoptium\jdk*") do (
        if not defined JAVA_HOME if exist "%%V\bin\javac.exe" set "JAVA_HOME=%%V"
    )
)
REM Fall back to whatever is on PATH.
if not defined JAVA_HOME (
    for /f "delims=" %%J in ('where javac.exe') do (
        if not defined JAVA_HOME set "JAVA_HOME=%%~dpJ.."
    )
)

if not defined JAVA_HOME (
    echo   [X] No JDK found.
    echo       Install a JDK 17 or newer, or set JAVA_HOME, then run this again.
    goto :fail
)
REM Strip a trailing backslash from JAVA_HOME. Comparing against a lone
REM backslash inside quotes breaks cmd's parser, so test its length instead.
if not "%JAVA_HOME%"=="" if "%JAVA_HOME:~-1%"=="\\" set "JAVA_HOME=%JAVA_HOME:~0,-1%"
echo       JAVA_HOME = %JAVA_HOME%

"%JAVA_HOME%\bin\java.exe" -version >nul 2>&1
if errorlevel 1 (
    echo   [X] JAVA_HOME points at a broken JDK: %JAVA_HOME%
    goto :fail
)

REM ---------------------------------------------------------------------------
REM  STEP 2 - Maven
REM ---------------------------------------------------------------------------
echo [2/7] Locating Maven...
set "MVN="
if exist "%MAVEN_DIR%\bin\mvn.cmd" (
    set "MVN=%MAVEN_DIR%\bin\mvn.cmd"
) else (
    REM Fall back to Maven on PATH.
    for /f "delims=" %%M in ('where mvn.cmd') do (
        if not defined MVN set "MVN=%%M"
    )
)
if not defined MVN (
    echo   [X] Maven not found.
    echo       Expected: %MAVEN_DIR%\bin\mvn.cmd
    echo       Or install Maven and add it to PATH.
    goto :fail
)
echo       Using %MVN%

REM ---------------------------------------------------------------------------
REM  STEP 3 - MySQL
REM ---------------------------------------------------------------------------
echo [3/7] Checking MySQL...
set "MYSQL="

REM Probe the official installer locations one at a time. Plain sequential
REM if-exists avoids the quoting traps of a for-loop over quoted paths.
if not defined MYSQL if exist "%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not defined MYSQL if exist "%ProgramFiles%\MySQL\MySQL Server 8.4\bin\mysql.exe" set "MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.4\bin\mysql.exe"
if not defined MYSQL if exist "%ProgramFiles%\MySQL\MySQL Server 8.3\bin\mysql.exe" set "MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.3\bin\mysql.exe"
if not defined MYSQL if exist "%ProgramFiles%\MySQL\MySQL Server 8.2\bin\mysql.exe" set "MYSQL=%ProgramFiles%\MySQL\MySQL Server 8.2\bin\mysql.exe"

REM Fall back to PATH.
if not defined MYSQL for /f "delims=" %%M in ('where mysql.exe') do if not defined MYSQL set "MYSQL=%%M"

REM Try to start the Windows service before giving up.
if not defined MYSQL goto :no_mysql_client

"%MYSQL%" --version >nul 2>&1
if errorlevel 1 goto :no_mysql_client

REM Is the server actually up? A one-second no-op query is the cheapest probe.
"%MYSQL%" -u %DB_USER% -p%DB_PASS% -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo       MySQL is not accepting connections - starting the service...
    net start MySQL80 >nul 2>&1
    net start MySQL >nul 2>&1
    timeout /t 3 /nobreak <nul >nul 2>nul
    "%MYSQL%" -u %DB_USER% -p%DB_PASS% -e "SELECT 1" >nul 2>&1
    if errorlevel 1 (
        echo   [X] Cannot connect to MySQL as %DB_USER%.
        echo       Start the MySQL service, or run:  net start MySQL80
        echo       Then make sure the credentials are %DB_USER% / %DB_PASS%
        echo       and run this file again.
        goto :fail
    )
)
echo       MySQL is up.

REM --- Create the database, then apply schema, migration and demo data ---------
REM mysql.exe cannot run a file that contains the DELIMITER directive, so each
REM script is piped through stdin instead of redirected.
"%MYSQL%" -u %DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1

echo       Applying schema...
type "%APP_DIR%\database\college_db.sql" | "%MYSQL%" -u %DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 %DB_NAME% >nul 2>&1
if errorlevel 1 (
    echo   [X] Schema import failed.
    goto :fail
)

echo       Applying migration (widens the role enum, adds natural keys)...
type "%APP_DIR%\database\migrate_schema.sql" | "%MYSQL%" -u %DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 %DB_NAME% >nul 2>&1
if errorlevel 1 (
    echo   [X] Migration failed.
    goto :fail
)

echo       Loading demo data...
type "%APP_DIR%\database\seed_demo_data.sql" | "%MYSQL%" -u %DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 %DB_NAME% >nul 2>&1
if errorlevel 1 (
    echo   [X] Demo data import failed.
    goto :fail
)
echo       Database ready: %DB_NAME%
goto :db_done

:no_mysql_client
echo   [X] mysql.exe not found.
echo       Install MySQL 8 (https://dev.mysql.com/downloads/installer/) or add
echo       its bin folder to PATH, then run this again.
goto :fail

:db_done

REM ---------------------------------------------------------------------------
REM  STEP 4 - Build
REM ---------------------------------------------------------------------------
echo [4/7] Building %WAR_NAME%.war ...
pushd "%APP_DIR%"
call "%MVN%" -q -f "%APP_DIR%\pom.xml" clean package -DskipTests
set "BUILD_RC=%ERRORLEVEL%"
popd
if not "%BUILD_RC%"=="0" (
    echo   [X] Build failed. Scroll up for the compiler error.
    goto :fail
)
if not exist "%APP_DIR%\target\%WAR_NAME%.war" (
    echo   [X] Build finished but %WAR_NAME%.war is missing.
    goto :fail
)
echo       Build OK.

REM ---------------------------------------------------------------------------
REM  STEP 5 - Deploy to Tomcat
REM ---------------------------------------------------------------------------
echo [5/7] Deploying to Tomcat ...
if not exist "%TOMCAT_DIR%\bin\startup.bat" (
    echo   [X] Tomcat not found at: %TOMCAT_DIR%
    echo       Extract apache-tomcat-10.1 into: %ROOT%
    goto :fail
)

REM Stop any running instance so the new WAR is picked up on startup.
if exist "%TOMCAT_DIR%\bin\shutdown.bat" (
    call "%TOMCAT_DIR%\bin\shutdown.bat" >nul 2>&1
)
REM Give it a moment, then make sure nothing is still holding port 8080.
timeout /t 4 /nobreak <nul >nul 2>nul
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /R /C:":%PORT% .*LISTENING"') do (
    taskkill /F /PID %%P >nul 2>&1
)
REM Remove the exploded copy so Tomcat re-explodes the fresh WAR.
if exist "%TOMCAT_DIR%\webapps\%WAR_NAME%" rmdir /S /Q "%TOMCAT_DIR%\webapps\%WAR_NAME%" <nul 2>nul
if exist "%TOMCAT_DIR%\work\Catalina\localhost\%WAR_NAME%" rmdir /S /Q "%TOMCAT_DIR%\work\Catalina\localhost\%WAR_NAME%" <nul 2>nul

copy /Y "%APP_DIR%\target\%WAR_NAME%.war" "%TOMCAT_DIR%\webapps\%WAR_NAME%.war" >nul
if errorlevel 1 (
    echo   [X] Could not copy the WAR into Tomcat's webapps folder.
    goto :fail
)
echo       WAR deployed.

REM ---------------------------------------------------------------------------
REM  STEP 6 - Start Tomcat
REM ---------------------------------------------------------------------------
echo [6/7] Starting Tomcat ...
REM Tomcat's scripts need these in the environment of the new process.
set "CATALINA_HOME=%TOMCAT_DIR%"
set "CATALINA_BASE=%TOMCAT_DIR%"
set "JAVA_HOME=%JAVA_HOME%"
set "JAVA_OPTS=-Xms256m -Xmx1024m -Dfile.encoding=UTF-8"

call "%TOMCAT_DIR%\bin\startup.bat" >nul 2>&1
echo       Waiting for the application to become healthy ...

REM Poll the health endpoint until it reports UP (or we give up).
REM Flat loop, no nested blocks: much easier for cmd to parse reliably.
set "READY="
set /a TRIES=0
:wait_health
set /a TRIES+=1
if %TRIES% GTR 60 goto :health_timeout

timeout /t 2 /nobreak <nul >nul 2>nul
REM <nul detaches stdin so curl never inherits a redirected console stream.
curl -s --max-time 4 "http://localhost:%PORT%%CONTEXT%/health" <nul > "%TEMP%\mg_health.txt" 2>nul
findstr /C:"UP" "%TEMP%\mg_health.txt" >nul 2>&1
if not errorlevel 1 (
    set "READY=1"
    del "%TEMP%\mg_health.txt" >nul 2>&1
    goto :health_ok
)
del "%TEMP%\mg_health.txt" >nul 2>&1
goto :wait_health

:health_ok
echo       Application is UP.
goto :after_health

:health_timeout
echo   [!] The health check did not pass within 120 seconds.
echo       Tomcat may still be starting. Opening the URL anyway.
echo       Check: %TOMCAT_DIR%\logs\localhost.log

:after_health

REM ---------------------------------------------------------------------------
REM  STEP 7 - Open the browser
REM ---------------------------------------------------------------------------
:open_browser
echo [7/7] Opening your browser ...
start "" "%URL%"

echo.
echo  ==========================================================================
echo    Mangaud CollegeHub is running.
echo.
echo    URL          : %URL%
echo    Tomcat       : %TOMCAT_DIR%
echo    Logs         : %TOMCAT_DIR%\logs\
echo.
echo    Demo sign-in - one click on the login screen, or:
echo      Administrator  admin        / Admin@123
echo      Teacher        teacher1..4  / Teacher@123
echo      Student        student1..8  / Student@123
echo      Parent         parent1      / Parent@123
echo      Accountant     accountant   / Accounts@123
echo      Librarian      librarian    / Library@123
echo      Hostel Warden  warden       / Warden@123
echo      Transport      transport    / Transport@123
echo  ==========================================================================
echo.

REM ---------------------------------------------------------------------------
REM  Small menu so the window stays useful instead of closing.
REM ---------------------------------------------------------------------------
:menu
echo  [R] Reopen browser    [L] View logs    [S] Stop server    [Q] Quit
echo.
set "CHOICE="
set /p "CHOICE=Choose: "
if /i "%CHOICE%"=="R" (
    start "" "%URL%"
    goto :menu
)
if /i "%CHOICE%"=="L" (
    start "" notepad.exe "%TOMCAT_DIR%\logs\localhost.log"
    goto :menu
)
if /i "%CHOICE%"=="S" (
    echo  Stopping Tomcat...
    call "%TOMCAT_DIR%\bin\shutdown.bat" >nul 2>&1
    echo  Stopped. The server is no longer running.
    goto :done
)
if /i "%CHOICE%"=="Q" goto :done
goto :menu

:fail
echo.
echo  ==========================================================================
echo    DEPLOYMENT FAILED - see the message above.
echo  ==========================================================================
echo.
pause
exit /b 1

:done
endlocal
exit /b 0
