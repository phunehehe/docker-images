include(CMakeFindDependencyMacro)
find_dependency(aws-c-common)
find_dependency(aws-checksums)

include(${CMAKE_CURRENT_LIST_DIR}/aws-c-event-stream-targets.cmake)

