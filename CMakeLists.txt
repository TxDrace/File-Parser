cmake_minimum_required(VERSION 3.10)
project(FileParser)

option(BUILD_SHARED "Build shared library" OFF)
if(BUILD_SHARED)
    set(LIB_TYPE SHARED)
else()
    set(LIB_TYPE STATIC)
endif()

# Code quality options
option(ENABLE_CLANG_TIDY "Enable clang-tidy checks" OFF)
option(ENABLE_CLANG_FORMAT "Enable clang-format checks" OFF)

set(CMAKE_CXX_STANDARD 11)



# Set up clang-tidy if enabled
if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
    if(CLANG_TIDY_EXE)
        message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXE}")
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    else()
        message(WARNING "clang-tidy requested but not found")
    endif()
endif()

# Set up clang-format if enabled (for custom targets)
if(ENABLE_CLANG_FORMAT)
    find_program(CLANG_FORMAT_EXE NAMES "clang-format")
    if(CLANG_FORMAT_EXE)
        message(STATUS "Found clang-format: ${CLANG_FORMAT_EXE}")
    else()
        message(WARNING "clang-format requested but not found")
    endif()
endif()

# Simple dependency management with vcpkg
find_package(ZLIB REQUIRED)

add_library(dummy ${LIB_TYPE}
    src/dummy.cpp
    src/compression.cpp
)

target_include_directories(dummy PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Handle Windows DLL exports properly
if(BUILD_SHARED AND WIN32)
    set_target_properties(dummy PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
endif()

target_link_libraries(dummy PUBLIC ZLIB::ZLIB)

add_executable(file_parser
    src/main.cpp
)

target_link_libraries(file_parser PRIVATE dummy)

enable_testing()
add_executable(dummy_test
    tests/dummy_test.cpp
)
target_link_libraries(dummy_test PRIVATE dummy)
add_test(NAME DummyTest COMMAND dummy_test)

# Code quality targets
if(CLANG_FORMAT_EXE)
    # Get all source files
    file(GLOB_RECURSE ALL_SOURCE_FILES
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/src/*.c
        ${CMAKE_SOURCE_DIR}/include/*.h
        ${CMAKE_SOURCE_DIR}/include/*.hpp
        ${CMAKE_SOURCE_DIR}/tests/*.cpp
        ${CMAKE_SOURCE_DIR}/tests/*.c
    )

    # Add target to format code
    add_custom_target(format
        COMMAND ${CLANG_FORMAT_EXE} -i ${ALL_SOURCE_FILES}
        COMMENT "Formatting code with clang-format"
        VERBATIM
    )

    # Add target to check formatting
    add_custom_target(format-check
        COMMAND ${CLANG_FORMAT_EXE} --dry-run --Werror ${ALL_SOURCE_FILES}
        COMMENT "Checking code formatting with clang-format"
        VERBATIM
    )
endif()

# Add target to run clang-tidy manually (even if CMAKE_CXX_CLANG_TIDY is not set)
if(CLANG_TIDY_EXE)
    # Get all source files
    file(GLOB_RECURSE TIDY_SOURCE_FILES
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/tests/*.cpp
    )
    
    add_custom_target(tidy
        COMMAND ${CLANG_TIDY_EXE} ${TIDY_SOURCE_FILES} -- -I${CMAKE_SOURCE_DIR}/include -I${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/include
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running clang-tidy checks"
        VERBATIM
        DEPENDS dummy file_parser dummy_test
    )
endif()

# Combined code quality check target
add_custom_target(code-quality)
if(CLANG_FORMAT_EXE)
    add_dependencies(code-quality format-check)
endif()
if(CLANG_TIDY_EXE)
    add_dependencies(code-quality tidy)
endif()
