cmake_minimum_required(VERSION 3.10)
project(FileParser)

set(CMAKE_CXX_STANDARD 11)

add_library(dummy STATIC
    src/dummy.cpp
)

target_include_directories(dummy PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_executable(file_parser
    src/main.cpp
)

target_link_libraries(file_parser PRIVATE dummy)
