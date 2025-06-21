#!/bin/bash

# Development helper script for code quality checks
# Usage: ./dev-quality.sh [format|check|tidy|all]

set -e

BUILD_DIR="build"
SOURCE_DIRS="src include tests"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_usage() {
    echo "Usage: $0 [format|check|tidy|all|help]"
    echo ""
    echo "Commands:"
    echo "  format  - Format all source files with clang-format"
    echo "  check   - Check formatting without modifying files"
    echo "  tidy    - Run clang-tidy on all source files"
    echo "  all     - Run all code quality checks"
    echo "  help    - Show this help message"
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
        exit 1
    fi
}

ensure_build_dir() {
    echo -e "${YELLOW}Configuring build directory with code quality tools...${NC}"
    cmake -B "$BUILD_DIR" -DENABLE_CLANG_FORMAT=ON -DENABLE_CLANG_TIDY=ON
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to configure build directory${NC}"
        exit 1
    fi
}

format_code() {
    echo -e "${GREEN}Formatting code...${NC}"
    ensure_build_dir
    cmake --build "$BUILD_DIR" --target format
    echo -e "${GREEN}Code formatting completed${NC}"
}

check_format() {
    echo -e "${GREEN}Checking code formatting...${NC}"
    ensure_build_dir
    if cmake --build "$BUILD_DIR" --target format-check; then
        echo -e "${GREEN}Code formatting is correct${NC}"
    else
        echo -e "${RED}Code formatting issues found. Run '$0 format' to fix them.${NC}"
        exit 1
    fi
}

run_tidy() {
    echo -e "${GREEN}Running clang-tidy...${NC}"
    ensure_build_dir
    cmake --build "$BUILD_DIR" --target tidy
    echo -e "${GREEN}clang-tidy completed${NC}"
}

run_all() {
    echo -e "${GREEN}Running all code quality checks...${NC}"
    check_format
    run_tidy
    echo -e "${GREEN}All code quality checks completed${NC}"
}

# Main script logic
case "${1:-help}" in
    format)
        check_tools
        format_code
        ;;
    check)
        check_tools
        check_format
        ;;
    tidy)
        check_tools
        run_tidy
        ;;
    all)
        check_tools
        run_all
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_usage
        exit 1
        ;;
esac
