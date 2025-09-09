#!/bin/bash
set -e

echo "Starting entrypoint script..."
echo "Build type: $BUILD_TYPE"

for device in /dev/ttyUSB* /dev/ttyACM* /dev/pcanusb* /dev/input/js*; do
  if [ -e "$device" ]; then
    sudo chmod 666 "$device"
    echo "$device"
  fi
done

# ROS 환경 설정
WORKSPACE_DIR=$HOME/ros_ws
source $WORKSPACE_DIR/ros2_settings.sh

if [ "$BUILD_TYPE" != "develop" ]; then
    ros2 launch farmily_launcher farmily_launch.py
fi

exec "$@"
