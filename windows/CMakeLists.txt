cmake_minimum_required(VERSION 3.14)
project(flutter_rust_ocr LANGUAGES CXX)

set(PLUGIN_NAME flutter_rust_ocr_plugin)

add_library(${PLUGIN_NAME} INTERFACE)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_link_libraries(${PLUGIN_NAME} INTERFACE
  flutter
  flutter_wrapper_plugin
)
