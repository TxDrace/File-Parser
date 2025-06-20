@echo off
REM Build script for Windows using vcpkg

echo === File Parser Build Script ===

REM Set vcpkg toolchain file
set CMAKE_TOOLCHAIN_FILE=%~dp0vcpkg\scripts\buildsystems\vcpkg.cmake

REM Clean previous build (optional)
if exist build (
    echo Cleaning previous build...
    rmdir /s /q build
)

REM Configure the project
echo Configuring project with vcpkg...
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE="%CMAKE_TOOLCHAIN_FILE%"
if %ERRORLEVEL% neq 0 (
    echo Configuration failed!
    exit /b 1
)

REM Build the project
echo Building project...
cmake --build build
if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b 1
)

REM Run tests
echo Running tests...
cmake --build build --target RUN_TESTS
if %ERRORLEVEL% neq 0 (
    echo Tests failed!
    exit /b 1
)

echo === Build completed successfully! ===
echo Executables are in: build\Debug\
echo - file_parser.exe
echo - dummy_test.exe
