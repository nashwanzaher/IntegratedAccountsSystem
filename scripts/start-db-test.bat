@echo off
REM =====================================================
REM  PostgreSQL DAL Connectivity Test - Quick Start
REM  Runs tests/IntegratedAccSys.DAL.DbTest
REM =====================================================

setlocal

set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..

echo.
echo === PostgreSQL DAL Connectivity Test ===
echo.
echo Project : tests\IntegratedAccSys.DAL.DbTest
echo.

REM Allow override of connection via env vars
if "%IAS_DB_SERVER%"=="" set IAS_DB_SERVER=localhost
if "%IAS_DB_PORT%"=="" set IAS_DB_PORT=5432
if "%IAS_DB_NAME%"=="" set IAS_DB_NAME=IntegratedAccSys
if "%IAS_DB_USER%"=="" set IAS_DB_USER=postgres
if "%IAS_DB_PWD%"=="" set IAS_DB_PWD=postgres
if "%IAS_DB_MODE%"=="" set IAS_DB_MODE=SQL

echo Connection:
echo   Server   : %IAS_DB_SERVER%:%IAS_DB_PORT%
echo   Database : %IAS_DB_NAME%
echo   User     : %IAS_DB_USER%
echo   Mode     : %IAS_DB_MODE%
echo.

cd /d "%ROOT_DIR%"
dotnet run --project tests\IntegratedAccSys.DAL.DbTest\IntegratedAccSys.DAL.DbTest.csproj %*
echo.

endlocal
