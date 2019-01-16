cmake_minimum_required(VERSION 3.10)
project(foobar)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist CACHE PATH "..." FORCE)
endif()

list(INSERT CMAKE_PREFIX_PATH 0  ${CMAKE_SOURCE_DIR})

add_subdirectory(bar)

add_subdirectory(foo)