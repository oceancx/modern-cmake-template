cmake_minimum_required(VERSION 3.10)
project(Foo VERSION 1.0.0 LANGUAGES C CXX)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist CACHE PATH "..." FORCE)
endif()

#add_subdirectory(dependency/bar)
find_package(Bar) 

file(GLOB Foo_PUBLIC_HEADERS "include/*.h" "include/*.hpp" "include/*.inl")
file(GLOB Foo_PRIVATE_HEADERS "include/*.h" "include/*.hpp" "include/*.inl")

add_library(foo
    src/foo.cpp
    ${Foo_PUBLIC_HEADERS}
    ${Foo_RPIVATE_HEADERS}
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

include(cmake/HelperMacroFunction.cmake)
export_library_macro(foo Foo Foo:: lib/cmake/foo)

add_executable(foox src/main.cpp)
target_link_libraries(foox foo)
