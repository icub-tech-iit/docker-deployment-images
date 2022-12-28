#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"

#FROM $START_IMG as builder

# Definitions
ARG ROS_IMG=ros:foxy-ros-core
# TODO Now it is working only with icub-main devel START_IMG IGNORED
ARG SUPERBUILD_IMG=icubteamcode/superbuild-icubhead:master-unstable_sources
ARG PROJECTS_DIR=/projects

FROM $SUPERBUILD_IMG as superbuild_builder
FROM $ROS_IMG as ros_builder

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="alexandre.gomespereira@iit.it, nicolo.genesio@iit.it, valentina.vasco@iit.it"

ARG PROJECTS_DIR

COPY --from=superbuild_builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=superbuild_builder /usr /usr
COPY --from=superbuild_builder /etc /etc

RUN apt update && apt install -y \
    ros-foxy-rqt ros-foxy-rqt-common-plugins \
    # building tool for ros
    python3-colcon-common-extensions \
    wget \
    unzip
RUN echo 'source "/opt/ros/$ROS_DISTRO/setup.bash"' >> /usr/local/bin/setup_robotology_tdd.sh

WORKDIR /root
RUN wget https://github.com/icub-tech-iit/appsAway/files/8919271/FT_setup.zip
RUN unzip FT_setup

WORKDIR /root
RUN wget https://github.com/icub-tech-iit/appsAway/files/9112222/FT_setup_can.zip
RUN unzip FT_setup_can

# TODO to be removed once it will merged on upstream branch
RUN cd ${PROJECTS_DIR} && git clone https://github.com/vvasco/yarp &&\
    cd yarp &&\
    git checkout feat/canftwriteapi &&\
    mkdir build && cd build &&\
    cmake .. &&\
    make install -j5

# TODO to be removed once it will merged on upstream branch
RUN cd ${PROJECTS_DIR} && git clone https://github.com/vvasco/icub-main &&\
    cd icub-main &&\
    git checkout feat/canftwriteapi &&\
    mkdir build && cd build &&\
    cmake .. \
        -DENABLE_icubmod_canBusFtSensor:BOOL=ON \
        -DENABLE_icubmod_canBusAnalogSenor:BOOL=ON \
        -DENABLE_icubmod_embObjFTsensor:BOOL=ON \
        &&\
    make install -j5


RUN bash -c "source /opt/ros/$ROS_DISTRO/setup.bash &&\
    echo $AMENT_PREFIX_PATH &&\
    echo $AMENT_CURRENT_PREFIX &&\
    cd ${PROJECTS_DIR} &&\
    git clone https://github.com/icub-tech-iit/yarp-ros2.git &&\
    cd yarp-ros2 &&\
    git checkout feat/canftwriteapi &&\
    mkdir build && cd build &&\
    cmake .. &&\
    make install -j5"


ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["bash"]
