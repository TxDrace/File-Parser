#!/bin/bash
# Development script with additional options

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CMAKE_TOOLCHAIN_FILE="$SCRIPT_DIR/vcpkg/scripts/buildsystems/vcpkg.cmake"

show_help() {
    echo "File Parser Development Script"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  build       Build the project (default)"
    echo "  clean       Clean build directory"
    echo "  test        Run tests only"
    echo "  run         Run the main executable"
    echo "  debug       Build in debug mode"
    echo "  release     Build in release mode"
    echo "  shared      Build with shared libraries"
    echo "  help        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 release"
    echo "  $0 shared"
    echo "  $0 clean build"
}

clean_build() {
    echo "Cleaning build directory..."
    if [ -d "build" ]; then
        rm -rf build
    fi
    echo "Build directory cleaned."
}

configure_project() {
    local build_type="${1:-Debug}"
    local shared_libs="${2:-OFF}"
    
    echo "Configuring project..."
    echo "  Build type: $build_type"
    echo "  Shared libs: $shared_libs"
    
    cmake -B build -S . \
        -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DBUILD_SHARED="$shared_libs"
}

build_project() {
    echo "Building project..."
    cmake --build build
}

run_tests() {
    echo "Running tests..."
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        cmake --build build --target RUN_TESTS
    else
        ctest --test-dir build
    fi
}

run_executable() {
    echo "Running file_parser..."
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        ./build/Debug/file_parser.exe
    else
        ./build/file_parser
    fi
}

# Parse command line arguments
BUILD_TYPE="Debug"
SHARED_LIBS="OFF"
COMMANDS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        build)
            COMMANDS+=("build")
            shift
            ;;
        clean)
            COMMANDS+=("clean")
            shift
            ;;
        test)
            COMMANDS+=("test")
            shift
            ;;
        run)
            COMMANDS+=("run")
            shift
            ;;
        debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        release)
            BUILD_TYPE="Release"
            shift
            ;;
        shared)
            SHARED_LIBS="ON"
            shift
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Default to build if no commands specified
if [ ${#COMMANDS[@]} -eq 0 ]; then
    COMMANDS=("build")
fi

# Execute commands in order
for cmd in "${COMMANDS[@]}"; do
    case $cmd in
        clean)
            clean_build
            ;;
        build)
            configure_project "$BUILD_TYPE" "$SHARED_LIBS"
            build_project
            ;;
        test)
            run_tests
            ;;
        run)
            run_executable
            ;;
    esac
done

echo "=== Development script completed! ==="
