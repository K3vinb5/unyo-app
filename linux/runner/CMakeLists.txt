cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
# Brand icon, embedded as a GResource so the GTK window/taskbar icon loads from
# the binary instead of a working-directory-relative file (WP #84). The PNG is
# generated from packaging/icons/source/unyo_1024.png by
# packaging/icons/generate.py; never edit it by hand.
find_program(GLIB_COMPILE_RESOURCES glib-compile-resources REQUIRED)
set(UNYO_ICON_DIR "${CMAKE_SOURCE_DIR}/../packaging/icons/linux/hicolor/512x512/apps")
set(UNYO_ICON_PNG "${UNYO_ICON_DIR}/logo.png")
set(UNYO_GRESOURCE_XML "${CMAKE_CURRENT_SOURCE_DIR}/resources/unyo.gresource.xml")
set(UNYO_RESOURCES_C "${CMAKE_CURRENT_BINARY_DIR}/unyo_resources.c")
add_custom_command(
  OUTPUT "${UNYO_RESOURCES_C}"
  COMMAND ${GLIB_COMPILE_RESOURCES}
    --sourcedir "${UNYO_ICON_DIR}"
    --target "${UNYO_RESOURCES_C}"
    --generate-source
    --c-name unyo
    "${UNYO_GRESOURCE_XML}"
  DEPENDS "${UNYO_GRESOURCE_XML}" "${UNYO_ICON_PNG}"
  COMMENT "Compiling the Unyo brand icon into the runner"
  VERBATIM
)

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${UNYO_RESOURCES_C}"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
