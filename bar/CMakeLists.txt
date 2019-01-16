cmake_minimum_required(VERSION 3.10)
project(Bar VERSION 1.0.0 LANGUAGES C CXX)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist CACHE PATH "..." FORCE)
endif()

add_library(bar INTERFACE)
target_include_directories(bar
    INTERFACE
        $<INSTALL_INTERFACE:include>
)

target_compile_features(bar INTERFACE cxx_std_11)
target_link_libraries(bar INTERFACE Bar::Bar)

set(PROJ_CONFIG_DIR lib/cmake/bar)
set(PROJ_EXPORT_NAME Bar)
set(PROJ_EXPORT_NAMESPACE Bar::)
set(PROJ_TARGET bar)
add_library("${PROJ_EXPORT_NAMESPACE}${PROJ_EXPORT_NAME}" ALIAS bar)
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