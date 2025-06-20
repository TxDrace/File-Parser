cmake_minimum_required(VERSION 3.10)
project(FileParser)

option(BUILD_SHARED "Build shared library" OFF)
if(BUILD_SHARED)
    set(LIB_TYPE SHARED)
else()
    set(LIB_TYPE STATIC)
endif()

set(CMAKE_CXX_STANDARD 11)

# Simple dependency management with vcpkg
find_package(ZLIB REQUIRED)

add_library(dummy ${LIB_TYPE}
    src/dummy.cpp
    src/compression.cpp
)

target_include_directories(dummy PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

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
