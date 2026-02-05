cmake_minimum_required(VERSION 3.10)
project(rime-predict)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


option(BUILD_TOOLS "Build tools" ON)

include_directories(/opt/homebrew/include)
include_directories(src)
include_directories(include)
link_directories(/opt/homebrew/lib)
set(rime_library rime marisa yaml-cpp glog)
set(rime_dict_library rime)


aux_source_directory(src predict_src)

add_library(rime-predict-objs OBJECT ${predict_src})
if(BUILD_SHARED_LIBS)
  set_target_properties(rime-predict-objs
    PROPERTIES
    POSITION_INDEPENDENT_CODE ON)
endif()

set(plugin_name rime-predict PARENT_SCOPE)
set(plugin_objs $<TARGET_OBJECTS:rime-predict-objs> PARENT_SCOPE)
set(plugin_deps ${rime_library} PARENT_SCOPE)
set(plugin_modules "predict" PARENT_SCOPE)

if(BUILD_TOOLS)
  add_subdirectory(tools)
endif()



