cmake_minimum_required(VERSION 3.10)
project(Foo VERSION 1.0.0 LANGUAGES C CXX)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist CACHE PATH "..." FORCE)
endif()

#add_subdirectory(dependency/bar)
find_package(Bar) 

add_library(foo
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

set(PROJ_CONFIG_DIR lib/cmake/foo)
set(PROJ_EXPORT_NAME Foo)
set(PROJ_EXPORT_NAMESPACE Foo::)
set(PROJ_TARGET foo)
add_library("${PROJ_EXPORT_NAMESPACE}${PROJ_EXPORT_NAME}" ALIAS foo)
set_target_properties(${PROJ_TARGET} PROPERTIES EXPORT_NAME ${PROJ_EXPORT_NAME})

install(TARGETS ${PROJ_TARGET}
    EXPORT  ${PROJ_EXPORT_NAME}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(DIRECTORY include/ DESTINATION include)
install(EXPORT ${PROJ_EXPORT_NAME}Targets
    FILE
        ${PROJ_EXPORT_NAME}Targets.cmake 
    NAMESPACE
        ${PROJ_EXPORT_NAMESPACE}
    DESTINATION
        ${PROJ_CONFIG_DIR}
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJ_EXPORT_NAME}ConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(${PROJ_EXPORT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJ_EXPORT_NAME}Config.cmake
    INSTALL_DESTINATION ${PROJ_CONFIG_DIR}
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJ_EXPORT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJ_EXPORT_NAME}ConfigVersion.cmake
    DESTINATION ${PROJ_CONFIG_DIR}
)

export(EXPORT ${PROJ_EXPORT_NAME}Targets FILE ${CMAKE_CURRENT_BINARY_DIR}/${PROJ_EXPORT_NAME}Targets.cmake  NAMESPACE ${PROJ_EXPORT_NAMESPACE})
export(PACKAGE ${PROJ_EXPORT_NAME})

add_executable(foox src/main.cpp)
target_link_libraries(foox foo)
