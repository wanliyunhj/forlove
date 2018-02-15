cmake_minimum_required(VERSION 3.8)
project(forlove)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(INC_DIR thirdlibs/linux/include)
set(LINK_DIR thirdlibs/linux/lib)

include_directories(${INC_DIR})
link_directories(${LINK_DIR})

set(SOURCE_FILES src/main.cpp)
add_executable(forlove ${SOURCE_FILES})

target_link_libraries(forlove
        libevent.a
        libevent_core.a
        libevent_extra.a
        libevent_pthreads.a
        )