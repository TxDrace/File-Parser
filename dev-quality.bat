@echo off
REM Development helper script for code quality checks
REM Usage: dev-quality.bat [format|check|tidy|all]

setlocal enabledelayedexpansion

set "BUILD_DIR=build"
set "COMMAND=%~1"

if "%COMMAND%"=="" set "COMMAND=help"

goto :%COMMAND% 2>nul || goto :unknown_command

:help
echo Usage: %0 [format^|check^|tidy^|all^|help]
echo.
echo Commands:
echo   format  - Format all source files with clang-format
echo   check   - Check formatting without modifying files
echo   tidy    - Run clang-tidy on all source files
echo   all     - Run all code quality checks
echo   help    - Show this help message
goto :end

:check_tools
where clang-format >nul 2>&1
if errorlevel 1 (
    echo Error: clang-format not found
    echo Please install LLVM/Clang tools and add them to PATH
    exit /b 1
)

where clang-tidy >nul 2>&1
if errorlevel 1 (
    echo Error: clang-tidy not found
    echo Please install LLVM/Clang tools and add them to PATH
    exit /b 1
)
goto :eof

:ensure_build_dir
echo Configuring build directory with code quality tools...
cmake -B "%BUILD_DIR%" -DENABLE_CLANG_FORMAT=ON -DENABLE_CLANG_TIDY=ON
if errorlevel 1 (
    echo Failed to configure build directory
    exit /b 1
)
goto :eof

:format
call :check_tools
if errorlevel 1 exit /b 1

echo Formatting code...
call :ensure_build_dir
if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --target format
if errorlevel 1 (
    echo Code formatting failed
    exit /b 1
)
echo Code formatting completed
goto :end

:check
call :check_tools
if errorlevel 1 exit /b 1

echo Checking code formatting...
call :ensure_build_dir
if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --target format-check
if errorlevel 1 (
    echo Code formatting issues found. Run '%0 format' to fix them.
    exit /b 1
)
echo Code formatting is correct
goto :end

:tidy
call :check_tools
if errorlevel 1 exit /b 1

echo Running clang-tidy...
call :ensure_build_dir
if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --target tidy
if errorlevel 1 (
    echo clang-tidy found issues
    exit /b 1
)
echo clang-tidy completed
goto :end

:all
call :check_tools
if errorlevel 1 exit /b 1

echo Running all code quality checks...
call :check
if errorlevel 1 exit /b 1

call :tidy
if errorlevel 1 exit /b 1

echo All code quality checks completed
goto :end

:unknown_command
echo Unknown command: %COMMAND%
echo.
goto :help

:end
endlocal
