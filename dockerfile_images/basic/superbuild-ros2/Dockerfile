# TODO: remove or correct
#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"

#FROM $START_IMG as builder

# Definitions
ARG ROS_IMG=ros:humble-ros-base-jammy
ARG ROS_DISTRO=humble
# TODO Now it is working only with icub-main devel START_IMG IGNORED
#ARG SUPERBUILD_IMG=icubteamcode/superbuild-icubhead:master-unstable_sources
# ARG SUPERBUILD_IMG=test-superbuild-icubhead:jammy
ARG PROJECTS_DIR=/projects

FROM $START_IMG as superbuild_builder
FROM $ROS_IMG as ros_builder

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG PROJECTS_DIR

COPY --from=superbuild_builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=superbuild_builder /usr /usr
COPY --from=superbuild_builder /etc /etc

RUN apt update && apt install -y \
    ros-humble-rqt ros-humble-rqt-common-plugins ros-humble-test-msgs ros-humble-desktop ros-dev-tools \
    ros-humble-rmw-cyclonedds-cpp ros-humble-ament-cmake-clang-format ros-humble-hardware-interface ros-humble-controller-manager ros-humble-ros2-control \
    wget \
    unzip
RUN echo 'source /opt/ros/humble/setup.bash' >> /usr/local/bin/setup_robotology_tdd.sh

WORKDIR /root
RUN wget https://github.com/icub-tech-iit/appsAway/files/8919271/FT_setup.zip
RUN unzip FT_setup

WORKDIR /root
RUN wget https://github.com/icub-tech-iit/appsAway/files/9112222/FT_setup_can.zip
RUN unzip FT_setup_can

# TODO to be removed once it will merged on upstream branch
# RUN cd ${PROJECTS_DIR} && git clone https://github.com/robotology/yarp &&\
#     cd yarp &&\
#     git checkout master &&\
#     mkdir build && cd build &&\
#     cmake .. &&\
#     make install -j5

# TODO to be removed once it will merged on upstream branch
# RUN cd ${PROJECTS_DIR} && git clone -b master https://github.com/robotology/icub-main &&\
#     cd icub-main &&\
#     mkdir build && cd build &&\
#     cmake .. \
#         -DENABLE_icubmod_canBusFtSensor:BOOL=OFF \
#         -DENABLE_icubmod_canBusAnalogSensor:BOOL=OFF \
#         -DENABLE_icubmod_embObjFTsensor:BOOL=ON \
#         &&\
#     make install -j5


RUN bash -c "source /opt/ros/$ROS_DISTRO/setup.bash &&\
    echo $AMENT_PREFIX_PATH &&\
    echo $AMENT_CURRENT_PREFIX &&\
    cd ${PROJECTS_DIR} &&\
    git clone -b master https://github.com/robotology/yarp-devices-ros2.git &&\
    cd yarp-devices-ros2/ros2_interfaces_ws &&\
    colcon build &&\
    source install/setup.bash &&\
    cd .. &&\
    mkdir build && cd build &&\
    cmake .. &&\
    make install -j5"

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["bash"]
