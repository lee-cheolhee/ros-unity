# Base image
FROM ghcr.io/lee-cheolhee/ros-docker:humble
LABEL authors="lee-cheolhee"
ARG DEBIAN_FRONTEND=noninteractive

ARG PROJDIR="ros_ws"
ARG BUILD_TYPE
ENV BUILD_TYPE=${BUILD_TYPE}
# ----------------------------------------------------------------------------------------------
RUN apt update && apt install -y ros-humble-navigation2 ros-humble-nav2-bringup \
    ros-humble-moveit ros-humble-moveit-resources-prbt-moveit-config \
    ros-humble-ros2-control ros-humble-ros2-controllers ros-humble-xacro \
    python3-colcon-common-extensions
# ----------------------------------------------------------------------------------------------
RUN id -u && id -g
ARG UID=1000
ARG GID=1000
ARG HOME=/home/appuser
ARG USER=appuser

RUN useradd -u $UID -d $HOME -m -s /bin/bash $USER && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && \
    usermod -aG sudo,plugdev $USER
# ----------------------------------------------------------------------------------------------
USER $USER
WORKDIR $HOME/${PROJDIR}/src

RUN git clone https://github.com/Unity-Technologies/ROS-TCP-Endpoint.git
# ----------------------------------------------------------------------------------------------
WORKDIR $HOME
RUN git clone https://github.com/lee-cheolhee/serial.git && \
    cd $HOME/serial && \
    mkdir build && \
    cd $HOME/serial/build && \
    cmake -DCMAKE_PREFIX_PATH=/opt/ros/noetic -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_INSTALL_PREFIX=/usr/local .. && cmake --build . -j4 && \
    sudo cmake --install .
# ----------------------------------------------------------------------------------------------
WORKDIR $HOME
RUN git clone https://github.com/koide3/small_gicp.git && \
    cd $HOME/small_gicp && \
    mkdir build && \
    cd $HOME/small_gicp/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && cmake --build . -j4 && \
    sudo cmake --install .
# ----------------------------------------------------------------------------------------------
RUN echo 'source ~/ros_ws/ros2_settings.sh' >> $HOME/.bashrc
# ----------------------------------------------------------------------------------------------
ADD entrypoint.sh $HOME/entrypoint.sh
ADD ros2_settings.sh $HOME/ros_ws/ros2_settings.sh
# ENTRYPOINT ["$HOME/entrypoint.sh"]
CMD ["bash"]
