@echo off
REM ============================================================================
REM  Mangaud CollegeHub
REM
REM  This script has been replaced by run.bat in the parent folder, which does
REM  the whole job: finds the JDK, starts MySQL, applies the schema + migration
REM  + demo data, builds the WAR, deploys to Tomcat, waits until the app is
REM  healthy, and opens your browser.
REM
REM  Double-click run.bat instead.
REM ============================================================================
echo.
echo   Mangaud CollegeHub
echo   -----------------------
echo.
echo   Use run.bat instead - it is one folder up and does everything:
echo   build, database, deploy, start Tomcat and open the browser.
echo.
if /i "%~1"=="--run" goto :run
echo   Press any key to close this window.
pause >nul
exit /b 0

:run
call "%~dp0..\run.bat"
