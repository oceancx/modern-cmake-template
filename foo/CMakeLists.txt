cmake_minimum_required(VERSION 3.10)
project(Foo VERSION 1.0.0 LANGUAGES C CXX)
include(cmake/cotire.cmake)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist CACHE PATH "..." FORCE)
endif()

#add_subdirectory(dependency/bar)
find_package(Bar) 


file(GLOB_RECURSE  SOURCES_CPP "src/*.cpp")
file(GLOB_RECURSE  SOURCES_HEADER_RPI "src/*.h" "src/*.hpp" "src/*.inl" )
file(GLOB_RECURSE  SOURCES_HEADER_PUB "include/*.h" "include/*.hpp" "include/*.inl")

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/src PREFIX "Source Files"  FILES ${SOURCES_CPP})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/src PREFIX "Header Files"  FILES ${SOURCES_HEADER_RPI})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/include PREFIX "Header Files\\include"  FILES ${SOURCES_HEADER_PUB})

add_library(foo
    ${SOURCES_HEADER_PUB}
    ${SOURCES_HEADER_RPI}
    src/foo.cpp
)
if(WIN32)
	target_sources(foo PRIVATE    
		src/foo_win.cpp
	)
elseif(UNIX)
	target_sources(foo PRIVATE    
		src/foo_posix.cpp
	)
endif()

if(MSVC)
  target_compile_options(cxbase PRIVATE /W4 /WX /wd4324 /wd4201 /wd4819)
else
  target_compile_options(cxbase PRIVATE -Wall -Wextra -pedantic -Werror)
endif(MSVC)


target_include_directories(foo
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

if(WIN32)
    target_compile_definitions(foo
        PUBLIC
            -DNOMINMAX 
            -DUNICODE 
            -DWIN32_LEAN_AND_MEAN
    )
endif()

target_compile_features(foo PUBLIC cxx_std_11)
target_link_libraries(foo PUBLIC Bar::Bar)

set_target_properties(foo PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "src/pch/precompile.h")
cotire(foo)

include(cmake/HelperMacroFunction.cmake)
export_library_macro(foo Foo Foo:: lib/cmake/foo)

add_executable(foox src/main.cpp)
target_link_libraries(foox foo)
