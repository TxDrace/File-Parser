#!/bin/bash
# Development script with additional options

set -e

# ============================================================================
# INITIALIZATION AND CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CMAKE_TOOLCHAIN_FILE="$SCRIPT_DIR/vcpkg/scripts/buildsystems/vcpkg.cmake"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# HELP FUNCTIONS
# ============================================================================

show_help() {
    echo "File Parser Development Script"
    echo "Usage: $0 [command] [subcommand/options]"
    echo ""
    echo "AVAILABLE COMMANDS:"
    echo "  build       Build the project (use 'build help' for options)"
    echo "  test        Run tests (use 'test help' for options)"
    echo "  run         Run the main executable (forward arguments)"
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
    echo "  $0 run zip archive.zip"
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
    echo "  run         Run tests"
    echo "  coverage    Run tests with coverage report"
    echo ""
    echo "Examples:"
    echo "  $0 test run"
    echo "  $0 test coverage"
}

show_quality_help() {
    echo "Quality Commands and Options"
    echo "Usage: $0 quality [subcommand]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  format      Format code using clang-format"
    echo "  check       Check formatting without modifying files"
    echo "  lint        Run static analysis (clang-tidy)"
    echo "  all         Run all quality checks"
    echo ""
    echo "Examples:"
    echo "  $0 quality format"
    echo "  $0 quality check"
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

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

check_build_directory() {
    local message="${1:-Build directory not found. Please run a build command first.}"
    local use_colors="${2:-true}"
    
    if [ ! -d "build" ]; then
        if [ "$use_colors" = "true" ]; then
            echo -e "${RED}${message}${NC}"
        else
            echo "$message"
        fi
        return 1
    fi
    return 0
}

check_tools() {
    local missing_tools=0
    
    if ! command -v clang-format &> /dev/null; then
        echo -e "${RED}Error: clang-format not found${NC}"
        missing_tools=1
    fi
    
    if ! command -v clang-tidy &> /dev/null; then
        echo -e "${RED}Error: clang-tidy not found${NC}"
        missing_tools=1
    fi
    
    if [ $missing_tools -eq 1 ]; then
        echo -e "${YELLOW}Please install LLVM/Clang tools${NC}"
        return 1
    fi
}

show_version() {
    echo "File Parser Development Script"
    echo "Version: 1.0.0"
    echo "CMake toolchain: $CMAKE_TOOLCHAIN_FILE"
}

install_executable() {
    echo "Installing executable..."
    
    # Check if build directory exists
    if ! check_build_directory; then
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

# ============================================================================
# BUILD FUNCTIONS
# ============================================================================

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
    
    # For Windows/Visual Studio generators, we need to specify the configuration at build time
    local build_config="Debug"
    if [ -f "build/CMakeCache.txt" ]; then
        local cache_build_type=$(grep "CMAKE_BUILD_TYPE:" build/CMakeCache.txt | cut -d= -f2)
        if [ -n "$cache_build_type" ]; then
            build_config="$cache_build_type"
        fi
    fi
    
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "Building for configuration: $build_config"
        cmake --build build --config "$build_config"
    else
        cmake --build build
    fi
}

# ============================================================================
# CODE QUALITY FUNCTIONS
# ============================================================================

check_quality_tools_enabled() {
    local format_enabled="OFF"
    local tidy_enabled="OFF"
    
    if [ -f "build/CMakeCache.txt" ]; then
        if grep -q "ENABLE_CLANG_FORMAT:BOOL=ON" build/CMakeCache.txt; then
            format_enabled="ON"
        fi
        if grep -q "ENABLE_CLANG_TIDY:BOOL=ON" build/CMakeCache.txt; then
            tidy_enabled="ON"
        fi
    fi
    
    echo "$format_enabled $tidy_enabled"
}

ensure_quality_tools_enabled() {
    echo "Checking code quality tools configuration..."
    
    # Check current settings
    read format_enabled tidy_enabled <<< "$(check_quality_tools_enabled)"
    
    local needs_reconfigure=false
    local cmake_args=()
    
    if [ "$format_enabled" != "ON" ]; then
        echo "  Enabling clang-format..."
        cmake_args+=("-DENABLE_CLANG_FORMAT=ON")
        needs_reconfigure=true
    else
        echo "  clang-format already enabled"
    fi
    
    if [ "$tidy_enabled" != "ON" ]; then
        echo "  Enabling clang-tidy..."
        cmake_args+=("-DENABLE_CLANG_TIDY=ON")
        needs_reconfigure=true
    else
        echo "  clang-tidy already enabled"
    fi
    
    if [ "$needs_reconfigure" = true ]; then
        echo "Reconfiguring build with quality tools..."
        cmake -B build "${cmake_args[@]}"
        echo "Code quality tools enabled."
    else
        echo "Code quality tools already enabled."
    fi
}

format_code() {
    echo -e "${GREEN}Formatting code...${NC}"
    if ! check_tools; then
        return 1
    fi
    
    # Ensure build directory is configured with code quality tools
    if ! check_build_directory; then
        return 1
    fi
    
    # Ensure quality tools are enabled (this function checks and enables if needed)
    ensure_quality_tools_enabled
    
    # Run code formatting using CMake target
    echo -e "${GREEN}Running code formatting using CMake target...${NC}"
    if cmake --build build --target format; then
        echo -e "${GREEN}Code formatting completed.${NC}"
    else
        echo -e "${RED}CMake format target failed. Please check for compilation errors or missing dependencies.${NC}"
        return 1
    fi
}

check_format() {
    echo -e "${GREEN}Checking code formatting...${NC}"
    if ! check_tools; then
        return 1
    fi
    
    # Ensure build directory is configured with code quality tools
    if ! check_build_directory; then
        return 1
    fi
    
    # Ensure quality tools are enabled (this function checks and enables if needed)
    ensure_quality_tools_enabled
    
    # Run format check using CMake target
    echo -e "${GREEN}Running format check using CMake target...${NC}"
    if cmake --build build --target format-check; then
        echo -e "${GREEN}Code formatting is correct${NC}"
    else
        echo -e "${RED}Code formatting issues found. Run '$0 quality format' to fix them.${NC}"
        return 1
    fi
}

lint_code() {
    echo -e "${GREEN}Running static analysis...${NC}"
    if ! check_tools; then
        return 1
    fi
    
    # Ensure build directory exists
    if ! check_build_directory; then
        return 1
    fi
    
    # Ensure quality tools are enabled (this function checks and enables if needed)
    ensure_quality_tools_enabled
    
    # Run clang-tidy target
    echo -e "${GREEN}Running static analysis using CMake target...${NC}"
    if cmake --build build --target tidy; then
        echo -e "${GREEN}Static analysis completed.${NC}"
    else
        echo -e "${RED}CMake tidy target failed. Please check for compilation errors or missing dependencies.${NC}"
        return 1
    fi
}

run_quality_all() {
    echo -e "${GREEN}Running all quality checks...${NC}"
    
    # Check for code quality tools
    if ! check_tools; then
        return 1
    fi
    
    # Run available quality checks
    echo -e "${GREEN}Running format check...${NC}"
    if ! check_format; then
        return 1
    fi
    
    echo -e "${GREEN}Running static analysis...${NC}"
    if ! lint_code; then
        return 1
    fi
    
    echo -e "${GREEN}All quality checks completed successfully.${NC}"
}

# ============================================================================
# TEST AND EXECUTION FUNCTIONS
# ============================================================================

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
        # On Windows with Visual Studio generator, try to find the executable
        # in the most likely locations (Debug first, then Release)
        local possible_paths=(
            "./build/Debug/file_parser.exe"
            "./build/Release/file_parser.exe"
            "./build/RelWithDebInfo/file_parser.exe"
            "./build/MinSizeRel/file_parser.exe"
        )
        
        for path in "${possible_paths[@]}"; do
            if [ -f "$path" ]; then
                executable_path="$path"
                break
            fi
        done
        
        if [ -z "$executable_path" ]; then
            echo "Executable not found in any of the expected locations:"
            for path in "${possible_paths[@]}"; do
                echo "  $path"
            done
            echo "Please run a build command first."
            return 1
        fi
    else
        executable_path="./build/file_parser"
    fi
    
    echo "Using executable: $executable_path"
    if [ -f "$executable_path" ]; then
        "$executable_path" "$@"
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

# ============================================================================
# COMMAND HANDLERS
# ============================================================================

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
        run)
            run_tests
            ;;
        coverage)
            run_coverage
            ;;
        "")
            show_test_help
            exit 0
            ;;
        *)
            echo "Unknown test command: $subcommand"
            show_test_help
            exit 1
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
        check)
            check_format
            ;;
        lint)
            lint_code
            ;;
        all)
            run_quality_all
            ;;
        "")
            show_quality_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown quality command: $subcommand${NC}"
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
        "")
            show_utility_help
            exit 0
            ;;
        *)
            echo "Unknown utility command: $subcommand"
            show_utility_help
            exit 1
            ;;
    esac
}

# ============================================================================
# MAIN SCRIPT EXECUTION
# ============================================================================

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
        run_executable "$@"
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
