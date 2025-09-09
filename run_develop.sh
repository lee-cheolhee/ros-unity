#!/bin/bash

REPO_NAME="ghcr.io/lee-cheolhee"
PROJECT_NAME="ros-unity"

# 인자가 있으면 그 값을 TAG로 사용, 없으면 git head를 검사하여 TAG를 설정
if [ -n "$1" ]; then
    TAG="$1"
    echo "Using TAG from argument: $TAG"
else
    remote_url=$(git config --get remote.origin.url)
    git_head=$(git rev-parse --abbrev-ref HEAD)
    if [ "$git_head" == "main" ]; then
        TAG=$(git describe --tags --exact-match 2>/dev/null)
    elif [ "$git_head" == "HEAD" ]; then
        TAG=$(git describe --tags --exact-match 2>/dev/null)
    else
        TAG="develop_ros2"
    fi
fi

echo "Using TAG: $TAG"

IP_ADDR=localhost
HOSTNAME=$(hostname)
USER=$(id -un)
DISP=:9

LOCAL_INC='/usr/local/include'
LOCAL_LIB='/usr/local/lib'

ENVS="--env=QT_X11_NO_MITSHM=1
      --env=XAUTHORITY=/root/.Xauthority
      --env=DISPLAY=$DISPLAY
      --env=LD_LIBRARY_PATH=$LOCAL_LIB:$LD_LIBRARY_PATH
      --env=ROS_IP=$IP_ADDR
      --env=ROS_HOSTNAME=$IP_ADDR
      --env=BUILD_TYPE=$TAG
      --device=/dev/dri:/dev/dri"

XSOCK=/tmp/.X11-unix
XAUTH=$HOME/.Xauthority
VOLUMES="--volume=$XSOCK:$XSOCK:ro
         --volume=$XAUTH:/root/.Xauthority:ro
         --volume=/dev:/dev:rw
         --volume=/etc/udev/rules.d:/etc/udev/rules.d:rw"
         #--volume=$HOME/html/data:/home/rdv/catkin_ws/install/share/farmily_web_ui/data"

MOUNTS="--mount type=bind,readonly,source=$LOCAL_INC,target=/usr/local/include
        --mount type=bind,readonly,source=$LOCAL_LIB,target=/usr/local/lib"

# ENTRYPOINT="bash"
ENTRYPOINT="$HOME/entrypoint.sh"

   # $MOUNTS \
   # --gpus all \
   # --entrypoint /bin/bash \
   # --user $(id -u):$(id -g) \
   # --cpus 3.0 \
   # --memory 7g \
   # --network host \
   # --volume=$HOME/html/data:/home/rdv/catkin_ws/src/farmily_web_ui/data \
if [ "$TAG" == "develop" ]; then
  docker run \
    -it \
    $ENVS \
    $VOLUMES \
    --volume=$PWD:$HOME/ros_ws:rw \
    --hostname $HOSTNAME \
    --user $(id -u):$(id -g) \
    --workdir $HOME/ros_ws \
    --privileged \
    --ipc host \
    -p 8765:8765 \
    --name ros-unity_${TAG} \
    $REPO_NAME/$PROJECT_NAME:latest bash
else
  docker run \
    -d \
    --restart unless-stopped \
    $ENVS \
    $VOLUMES \
    --volume=$PWD/install:$HOME/ros_ws/install:rw \
    --hostname $HOSTNAME \
    --user $(id -u):$(id -g) \
    --workdir $HOME/ros_ws \
    --privileged \
    --ipc host \
    --net host \
    --entrypoint $ENTRYPOINT \
    --name farmily_${TAG}_humble \
    $REPO_NAME/$PROJECT_NAME:humble bash
fi
