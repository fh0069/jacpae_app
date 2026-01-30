@echo off
REM Development runner script for Windows
REM This script loads environment variables and runs the Flutter app

REM Check if .env file exists
if not exist .env (
    echo ERROR: .env file not found!
    echo.
    echo Please create a .env file from .env.example:
    echo   1. Copy .env.example to .env
    echo   2. Fill in your Supabase credentials
    echo.
    pause
    exit /b 1
)

REM Load environment variables from .env file
for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
    set "%%a=%%b"
)

REM Check if required variables are set
if "%SUPABASE_URL%"=="" (
    echo ERROR: SUPABASE_URL not set in .env file
    pause
    exit /b 1
)

if "%SUPABASE_ANON_KEY%"=="" (
    echo ERROR: SUPABASE_ANON_KEY not set in .env file
    pause
    exit /b 1
)

REM Run Flutter with dart-define
echo Running Flutter app with Supabase configuration...
echo.
flutter run --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%
