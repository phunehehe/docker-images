#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "AWS::aws-c-common" for configuration "Release"
set_property(TARGET AWS::aws-c-common APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(AWS::aws-c-common PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "/nix/store/6gf53n9s2d7lqc2cmrlmhib227zl3akw-aws-c-common-0.3.11/lib/libaws-c-common.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS AWS::aws-c-common )
list(APPEND _IMPORT_CHECK_FILES_FOR_AWS::aws-c-common "/nix/store/6gf53n9s2d7lqc2cmrlmhib227zl3akw-aws-c-common-0.3.11/lib/libaws-c-common.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
