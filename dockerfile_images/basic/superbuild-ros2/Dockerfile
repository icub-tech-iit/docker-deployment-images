#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
ARG release="master"
ARG sbtag="Stable"
ARG metadata="data"

# Definitions
ARG ROS_IMG=ros:humble-ros-base-jammy
ARG ROS_DISTRO=humble
ARG PROJECTS_DIR=/projects
ARG INSTALL_DIR=${PROJECTS_DIR}/robotology-superbuild/build/install

FROM $START_IMG AS superbuild_builder
FROM $ROS_IMG AS ros_builder

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG ROS_DISTRO
ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG ROBOTOLOGY_INITIALIZATION_FILE

COPY --from=superbuild_builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=superbuild_builder /usr /usr
COPY --from=superbuild_builder /etc /etc

RUN apt update && apt install -y \
    ros-humble-rqt ros-humble-rqt-common-plugins ros-humble-test-msgs ros-humble-desktop ros-dev-tools \
    ros-humble-rmw-cyclonedds-cpp ros-humble-ament-cmake-clang-format ros-humble-hardware-interface ros-humble-controller-manager ros-humble-ros2-control \
    wget \
    unzip
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> ${ROBOTOLOGY_INITIALIZATION_FILE}


FROM $ROS_IMG AS secondstage

ARG ROS_DISTRO
ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG release
ARG sbtag
ARG metadata

COPY --from=ros_builder / /

ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4
ARG CMAKE_PREFIX_PATH=/usr/local

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}

RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash &&\
    echo $AMENT_PREFIX_PATH &&\
    echo $AMENT_CURRENT_PREFIX"
    
RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    cd build &&\
    cmake .. \
    -G "$CMAKE_GENERATOR" \
        -DCMAKE_INSTALL_PREFIX=${CMAKE_PREFIX_PATH} \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON \
        # for enabling yarp-devices-ros2
        -DROBOTOLOGY_ENABLE_ROS2:BOOL=ON \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        &&\
        # Build all the projects
        cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

ENV QT_X11_NO_MITSHM=1 
ENV YARP_COLORED_OUTPUT=1

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >>  $ROBOTOLOGY_INITIALIZATION_FILE

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["bash"]