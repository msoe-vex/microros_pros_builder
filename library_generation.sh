#!/bin/bash
PATH=$PATH:/uros_ws/gcc-arm-none-eabi-9-2020-q2-update/bin/
source /opt/ros/$ROS_DISTRO/setup.bash
source install/local_setup.bash

cd build

if [ ! -d firmware ]; then
    ros2 run micro_ros_setup create_firmware_ws.sh generate_lib
fi

ros2 run micro_ros_setup build_firmware.sh /v5_toolchain.cmake /v5_colcon.meta

LIB_PATH=../pros_firmware/libmicroros.a
INC_PATH=../pros_include/microros

find firmware/build/include/ -name "*.c"  -delete
rm -f $LIB_PATH
rm -rf $INC_PATH
mkdir -p $INC_PATH
cp -R firmware/build/include/* $INC_PATH
cp -R firmware/build/libmicroros.a $LIB_PATH

pushd firmware/mcu_ws > /dev/null
    INCLUDE_ROS2_PACKAGES=$(colcon list | awk '{print $1}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}')
popd > /dev/null

for var in ${INCLUDE_ROS2_PACKAGES}; do
    if [ -d "$INC_PATH/${var}/${var}" ]; then
        rsync -r $INC_PATH/${var}/${var}/* $INC_PATH/${var}
        rm -rf $LIB_PATH/${var}/${var}
    fi
done

echo "Fixing rcutils includes..."
grep -irlP "#include <rcutils.*>" $INC_PATH | xargs sed -i '/^#include <rcutils.*>/s/[<>]/"/g'
echo "Fixing rmw includes..."
grep -irlP "#include <rmw.*>"     $INC_PATH | xargs sed -i '/^#include <rmw.*>/s/[<>]/"/g'
echo "Fixing rcl includes..."
grep -irlP "#include <rcl.*>"     $INC_PATH | xargs sed -i '/^#include <rcl.*>/s/[<>]/"/g'
echo "Fixing uxr includes..."
grep -irlP "#include <uxr.*>"     $INC_PATH | xargs sed -i '/^#include <uxr.*>/s/[<>]/"/g'
echo "Fixing ucdr includes..."
grep -irlP "#include <ucdr.*>"    $INC_PATH | xargs sed -i '/^#include <ucdr.*>/s/[<>]/"/g'
echo "Fixing rosidl includes..."
grep -irlP "#include <rosidl.*>"    $INC_PATH | xargs sed -i '/^#include <rosidl.*>/s/[<>]/"/g'
