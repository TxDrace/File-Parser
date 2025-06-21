#!/bin/bash
# Development script with additional options

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CMAKE_TOOLCHAIN_FILE="$SCRIPT_DIR/vcpkg/scripts/buildsystems/vcpkg.cmake"

show_help() {
    echo "File Parser Development Script"
    echo "Usage: $0 [command] [subcommand/options]"
    echo ""
    echo "AVAILABLE COMMANDS:"
    echo "  build       Build the project (use 'build help' for options)"
    echo "  test        Run tests (use 'test help' for options)"
    echo "  run         Run the main executable"
    echo "  quality     Code quality tools (use 'quality help' for options)"
    echo "  utility     Utility commands (use 'utility help' for options)"
    echo ""
    echo "GLOBAL OPTIONS:"
    echo "  help        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 build help"
    echo "  $0 build release"
    echo "  $0 test coverage"
    echo "  $0 quality format"
}

show_build_help() {
    echo "Build Commands and Options"
    echo "Usage: $0 build [subcommand/option] [additional options...]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  help        Show this help"
    echo "  clean       Clean build directory"
    echo "  rebuild     Clean and build the project"
    echo ""
    echo "BUILD TYPES:"
    echo "  debug       Build in debug mode (default)"
    echo "  release     Build in release mode"
    echo ""
    echo "BUILD OPTIONS:"
    echo "  shared      Build with shared libraries"
    echo ""
    echo "Examples:"
    echo "  $0 build           # Show this help"
    echo "  $0 build clean     # Clean build directory"
    echo "  $0 build debug     # Build in debug mode"
    echo "  $0 build release   # Build in release mode"
    echo "  $0 build shared    # Build with shared libraries"
    echo "  $0 build release shared  # Build release with shared libraries"
}

show_test_help() {
    echo "Test Commands and Options"
    echo "Usage: $0 test [subcommand]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  coverage    Run tests with coverage report"
    echo ""
    echo "Examples:"
    echo "  $0 test"
    echo "  $0 test coverage"
}

show_quality_help() {
    echo "Quality Commands and Options"
    echo "Usage: $0 quality [subcommand]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  format      Format code using clang-format"
    echo "  lint        Run static analysis (clang-tidy)"
    echo "  all         Run all quality checks"
    echo ""
    echo "Examples:"
    echo "  $0 quality format"
    echo "  $0 quality lint"
    echo "  $0 quality all"
}

show_utility_help() {
    echo "Utility Commands and Options"
    echo "Usage: $0 utility [subcommand]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  install     Install the built executable"
    echo "  version     Show version information"
    echo ""
    echo "Examples:"
    echo "  $0 utility install"
    echo "  $0 utility version"
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
    
    local executable_path=""
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        executable_path="./build/Debug/file_parser.exe"
    else
        executable_path="./build/file_parser"
    fi
    
    if [ -f "$executable_path" ]; then
        "$executable_path"
    else
        echo "Executable not found at: $executable_path"
        echo "Please run 'build' first to compile the project."
        return 1
    fi
}

run_coverage() {
    echo "Running tests with coverage..."
    # Add coverage implementation here
    echo "Coverage report generation not implemented yet"
}

format_code() {
    echo "Formatting code..."
    if command -v clang-format &> /dev/null; then
        find src include tests -name "*.cpp" -o -name "*.h" | xargs clang-format -i
        echo "Code formatting completed."
    else
        echo "clang-format not found. Please install clang-format."
    fi
}

lint_code() {
    echo "Running static analysis..."
    if command -v clang-tidy &> /dev/null; then
        # Check if build directory exists and has been configured
        if [ ! -d "build" ]; then
            echo "Build directory not found. Please run 'build' first."
            return 1
        fi
        
        # Try to run clang-tidy target, but fall back to manual clang-tidy if target doesn't exist
        if cmake --build build --target tidy 2>/dev/null; then
            echo "Static analysis completed."
        else
            echo "No tidy target found in build system. Running clang-tidy manually..."
            if [ -f "compile_commands.json" ] || [ -f "build/compile_commands.json" ]; then
                find src include -name "*.cpp" -o -name "*.h" | head -5 | xargs clang-tidy
                echo "Manual static analysis completed."
            else
                echo "No compile_commands.json found. Please ensure your build system generates it."
                return 1
            fi
        fi
    else
        echo "clang-tidy not found. Please install clang-tidy."
        return 1
    fi
}

run_quality_all() {
    echo "Running all quality checks..."
    format_code
    lint_code
}

install_executable() {
    echo "Installing executable..."
    
    # Check if build directory exists
    if [ ! -d "build" ]; then
        echo "Build directory not found. Please run 'build' first."
        return 1
    fi
    
    # Try to install, but provide helpful message if install target doesn't exist
    if cmake --build build --target install 2>/dev/null; then
        echo "Installation completed."
    else
        echo "No install target configured in the CMake project."
        echo "You can manually copy the executable from the build directory."
        return 1
    fi
}

show_version() {
    echo "File Parser Development Script"
    echo "Version: 1.0.0"
    echo "CMake toolchain: $CMAKE_TOOLCHAIN_FILE"
}

# Handle grouped commands
handle_build_command() {
    local subcommand="$1"
    local build_type="$BUILD_TYPE"
    local shared_libs="$SHARED_LIBS"
    
    # If no arguments provided, show help
    if [[ $# -eq 0 ]]; then
        show_build_help
        exit 0
    fi
    
    case "$subcommand" in
        help|--help|-h)
            show_build_help
            exit 0
            ;;
        clean)
            clean_build
            ;;
        rebuild)
            clean_build
            configure_project "$build_type" "$shared_libs"
            build_project
            ;;
        debug|release|shared)
            # Process all build arguments
            args_to_process=("$@")
            
            for arg in "${args_to_process[@]}"; do
                case "$arg" in
                    debug)
                        build_type="Debug"
                        ;;
                    release)
                        build_type="Release"
                        ;;
                    shared)
                        shared_libs="ON"
                        ;;
                    *)
                        echo "Unknown build option: $arg"
                        show_build_help
                        exit 1
                        ;;
                esac
            done
            
            configure_project "$build_type" "$shared_libs"
            build_project
            ;;
        *)
            echo "Unknown build command: $subcommand"
            show_build_help
            exit 1
            ;;
    esac
}

handle_test_command() {
    local subcommand="$1"
    
    case "$subcommand" in
        help|--help|-h)
            show_test_help
            exit 0
            ;;
        coverage)
            run_coverage
            ;;
        ""|*)
            run_tests
            ;;
    esac
}

handle_quality_command() {
    local subcommand="$1"
    
    case "$subcommand" in
        help|--help|-h)
            show_quality_help
            exit 0
            ;;
        format)
            format_code
            ;;
        lint)
            lint_code
            ;;
        all)
            run_quality_all
            ;;
        "")
            run_quality_all
            ;;
        *)
            echo "Unknown quality command: $subcommand"
            show_quality_help
            exit 1
            ;;
    esac
}

handle_utility_command() {
    local subcommand="$1"
    
    case "$subcommand" in
        help|--help|-h)
            show_utility_help
            exit 0
            ;;
        install)
            install_executable
            ;;
        version)
            show_version
            ;;
        *)
            echo "Unknown utility command: $subcommand"
            show_utility_help
            exit 1
            ;;
    esac
}

# Parse command line arguments
BUILD_TYPE="Debug"
SHARED_LIBS="OFF"

# Show help if no arguments provided
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Parse main command
MAIN_COMMAND="$1"
shift

case "$MAIN_COMMAND" in
    build)
        handle_build_command "$@"
        ;;
    test)
        handle_test_command "$@"
        ;;
    run)
        run_executable
        ;;
    quality)
        handle_quality_command "$@"
        ;;
    utility)
        handle_utility_command "$@"
        ;;
    help|--help|-h)
        show_help
        exit 0
        ;;
    *)
        echo "Unknown command: $MAIN_COMMAND"
        show_help
        exit 1
        ;;
esac

echo "=== Development script completed! ==="
