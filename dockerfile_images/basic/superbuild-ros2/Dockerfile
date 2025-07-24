#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
ARG release="master"
ARG sbtag="Stable"
ARG metadata="data"

# Definitions
ARG ROS_IMG=ros:humble-ros-base-jammy
ARG PROJECTS_DIR=/projects
ARG INSTALL_DIR=${PROJECTS_DIR}/robotology-superbuild/build/install

FROM $START_IMG AS superbuild_builder
FROM $ROS_IMG AS ros_builder

ENV ROS_DISTRO=humble
ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG ROBOTOLOGY_INITIALIZATION_FILE

COPY --from=superbuild_builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=superbuild_builder /usr/local /usr/local

# Set locale
RUN apt update &&\ 
    apt install -y --no-install-recommends locales &&\
    locale-gen en_US en_US.UTF-8 &&\
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 &&\
    export LANG=en_US.UTF-8

# Setup sources
RUN apt update &&\
    apt install -y software-properties-common
    
RUN apt update &&\
    add-apt-repository -y universe
# Install ros2-apt-source package
RUN apt update &&\
    apt install curl tar gzip build-essential -y 
    
RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') &&\
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" &&\
    apt update &&\
    apt install -y /tmp/ros2-apt-source.deb

RUN apt update && apt install -y \
    ros-humble-rqt ros-humble-rqt-common-plugins ros-humble-test-msgs ros-humble-desktop ros-dev-tools \
    ros-humble-rmw-cyclonedds-cpp ros-humble-ament-cmake-clang-format ros-humble-hardware-interface ros-humble-controller-manager ros-humble-ros2-control \
    ros-humble-ament-cmake \
    wget \
    unzip 

RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> ${ROBOTOLOGY_INITIALIZATION_FILE}


FROM $ROS_IMG AS secondstage

ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG release
ARG sbtag
ARG metadata

# Copy all files from the first stage to have the same environment eliminating intermediate layers
COPY --from=ros_builder / /

ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4
ARG CMAKE_PREFIX_PATH=/usr/local

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}

ENV AMENT_PREFIX_PATH=/opt/ros/${ROS_DISTRO}

RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash" &&\
    echo 'AMENT_PREFIX_PATH:' \$AMENT_PREFIX_PATH &&\
    echo 'AMENT_CURRENT_PREFIX:' \$AMENT_CURRENT_PREFIX
    
# Add ros setup.bash to bashrc
RUN echo "\n\
source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

# Build the project
RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    ./scripts/install_apt_dependencies.sh &&\
    cd build &&\
    bash -c "\
    source /opt/ros/${ROS_DISTRO}/setup.bash &&\
    cmake .. \
        -G '${CMAKE_GENERATOR}' \
        -DCMAKE_PREFIX_PATH='/opt/ros/${ROS_DISTRO}:/projects/robotology-superbuild/build/install' \
        -DCMAKE_INSTALL_PREFIX='/usr/local:/opt/ros/${ROS_DISTRO}' \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_USES_ROS2:BOOL=ON \
        -DYCM_EP_DEVEL_MODE_yarp-devices-ros2:BOOL=OFF &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}"

ENV QT_X11_NO_MITSHM=1 
ENV YARP_COLORED_OUTPUT=1

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >>  $ROBOTOLOGY_INITIALIZATION_FILE

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["bash"]