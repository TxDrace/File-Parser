#!/bin/bash
# Build script for Linux/macOS/Windows (bash) using vcpkg

set -e  # Exit on any error

echo "=== File Parser Build Script ==="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set vcpkg toolchain file
export CMAKE_TOOLCHAIN_FILE="$SCRIPT_DIR/vcpkg/scripts/buildsystems/vcpkg.cmake"

# Clean previous build (optional)
if [ -d "build" ]; then
    echo "Cleaning previous build..."
    rm -rf build
fi

# Configure the project
echo "Configuring project with vcpkg..."
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE"

# Build the project
echo "Building project..."
cmake --build build

# Run tests
echo "Running tests..."
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    cmake --build build --target RUN_TESTS
else
    ctest --test-dir build
fi

echo "=== Build completed successfully! ==="
echo "Executables are in: build/"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "- file_parser.exe"
    echo "- dummy_test.exe"
else
    echo "- file_parser"
    echo "- dummy_test"
fi
