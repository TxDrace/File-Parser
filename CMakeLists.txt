# CMake configuration for File Parser project
# Minimum CMake version required for modern features
cmake_minimum_required(VERSION 3.10)

# Project name and basic configuration
project(FileParser)

# Build configuration options
# Option to build shared library instead of static library
option(BUILD_SHARED "Build shared library" OFF)
if(BUILD_SHARED)
    set(LIB_TYPE SHARED)
else()
    set(LIB_TYPE STATIC)
endif()

# Code quality tool options
# Enable static analysis and formatting tools
option(ENABLE_CLANG_TIDY "Enable clang-tidy checks" OFF)
option(ENABLE_CLANG_FORMAT "Enable clang-format checks" OFF)

# C++ standard configuration
# Require C++23 for the entire project
set(CMAKE_CXX_STANDARD 23)


# ============================================================================
# CODE QUALITY TOOLS SETUP
# ============================================================================

# Set up clang-tidy if enabled
# Clang-tidy provides static analysis and linting for C++ code
if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
    if(CLANG_TIDY_EXE)
        message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXE}")
        # Tích hợp clang-tidy vào quá trình build, trước khi mỗi file cpp biên dịch, clang-tidy sẽ được chạy để phân tích
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    else()
        message(WARNING "clang-tidy requested but not found")
    endif()
endif()

# Set up clang-format if enabled (for custom targets)
# Clang-format provides automatic code formatting
if(ENABLE_CLANG_FORMAT)
    find_program(CLANG_FORMAT_EXE NAMES "clang-format")
    if(CLANG_FORMAT_EXE)
        message(STATUS "Found clang-format: ${CLANG_FORMAT_EXE}")
    else()
        message(WARNING "clang-format requested but not found")
    endif()
endif()

# ============================================================================
# DEPENDENCIES
# ============================================================================

# Simple dependency management with vcpkg
# ZLIB is used for compression functionality
find_package(ZLIB REQUIRED)

# ============================================================================
# LIBRARY TARGET
# ============================================================================

# Create the main library (dummy) with compression functionality
# This library contains the core functionality of the file parser
add_library(dummy ${LIB_TYPE}
    src/dummy.cpp
    src/compression.cpp
    src/zip_reader.cpp
)

# Make include directory available to consumers of this library
target_include_directories(dummy PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Handle Windows DLL exports properly
# Required for building shared libraries on Windows
if(BUILD_SHARED AND WIN32)
    set_target_properties(dummy PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
endif()

# Link the library with its dependencies
# ZLIB is needed for compression functionality
target_link_libraries(dummy PUBLIC ZLIB::ZLIB)

# ============================================================================
# EXECUTABLE TARGET
# ============================================================================

# Create the main executable
add_executable(file_parser
    src/main.cpp
)

# Link the executable with the library
target_link_libraries(file_parser PRIVATE dummy)

# ============================================================================
# TESTING
# ============================================================================

# Enable testing framework
enable_testing()

# Google Test
find_package(GTest CONFIG REQUIRED)

# Create test executable
add_executable(dummy_test
    tests/dummy_test.cpp
    tests/sample_test.cpp
    tests/zip_reader_test.cpp
)

# Link test executable with Google Test and the library
target_link_libraries(dummy_test PRIVATE dummy GTest::gtest_main)

# Register the test with CTest
include(GoogleTest)
gtest_discover_tests(dummy_test)

# ============================================================================
# CODE QUALITY CUSTOM TARGETS
# ============================================================================

# Code quality targets
# These targets provide formatting and linting capabilities
if(CLANG_FORMAT_EXE)
    # Get all source files for formatting
    # Include all C/C++ source and header files
    file(GLOB_RECURSE ALL_SOURCE_FILES
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/src/*.c
        ${CMAKE_SOURCE_DIR}/include/*.h
        ${CMAKE_SOURCE_DIR}/include/*.hpp
        ${CMAKE_SOURCE_DIR}/tests/*.cpp
        ${CMAKE_SOURCE_DIR}/tests/*.c
    )

    # Add target to format code in-place
    # Usage: cmake --build . --target format
    add_custom_target(format
        COMMAND ${CLANG_FORMAT_EXE} -i ${ALL_SOURCE_FILES}
        COMMENT "Formatting code with clang-format"
        VERBATIM
    )

    # Add target to check formatting without modifying files
    # Usage: cmake --build . --target format-check
    add_custom_target(format-check
        COMMAND ${CLANG_FORMAT_EXE} --dry-run --Werror ${ALL_SOURCE_FILES}
        COMMENT "Checking code formatting with clang-format"
        VERBATIM
    )
endif()

# Add target to run clang-tidy manually (even if CMAKE_CXX_CLANG_TIDY is not set)
# Provides static analysis and coding standard checks
if(CLANG_TIDY_EXE)
    # Get all source files for tidy analysis
    # Only include implementation files (.cpp)
    file(GLOB_RECURSE TIDY_SOURCE_FILES
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/tests/*.cpp
    )
    
    # Add custom target for running clang-tidy
    # Usage: cmake --build . --target tidy
    add_custom_target(tidy
        COMMAND ${CLANG_TIDY_EXE} ${TIDY_SOURCE_FILES} -- -I${CMAKE_SOURCE_DIR}/include -I${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/include
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running clang-tidy checks"
        VERBATIM
        DEPENDS dummy file_parser dummy_test    )
endif()
