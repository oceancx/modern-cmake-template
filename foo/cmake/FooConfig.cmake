if(NOT TARGET Foo::Foo)
    include("${CMAKE_CURRENT_LIST_DIR}/FooTargets.cmake")
endif()