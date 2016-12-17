cmake_minimum_required(VERSION 3.6)
project(db_labs)

set(CMAKE_CXX_STANDARD 11)

include_directories(/usr/local/include/odbc)

set(SRC_LIST
        src/DB.h
        src/DB.cpp
)

add_executable(db_lab4 src/main.cpp ${SRC_LIST})
target_link_libraries(db_lab4 /usr/local/iODBC/lib/libiodbc.dylib)
