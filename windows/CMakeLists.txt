cmake_minimum_required(VERSION 3.14)
project(flutter_rust_ocr LANGUAGES CXX)

set(PLUGIN_NAME flutter_rust_ocr_plugin)

add_library(${PLUGIN_NAME} SHARED
  "flutter_rust_ocr_plugin.cpp"
  "flutter_rust_ocr_plugin.h"
  "flutter_rust_ocr_plugin_c_api.cpp"
  "include/flutter_rust_ocr/flutter_rust_ocr_plugin_c_api.h"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET "hidden"
)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_rust_ocr_bundled_libraries
  ""
  PARENT_SCOPE
)
