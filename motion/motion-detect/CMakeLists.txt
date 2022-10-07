cmake_minimum_required(VERSION 3.10)
project( MotionDetect )

find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_executable( motiondetect motion_detector.cpp )
target_link_libraries( motiondetect ${OpenCV_LIBS} gps )

add_executable( gpstest gpstest.cpp )
target_link_libraries(gpstest PUBLIC gps pthread )
target_compile_options(gpstest PUBLIC -O3 -fopenmp)

# add_executable( acoustic myacoustic.c )
# target_link_libraries(acoustic PUBLIC gps pthread  rt m)
# target_compile_options(acoustic PUBLIC -O3 -MMD -g -Wall)
