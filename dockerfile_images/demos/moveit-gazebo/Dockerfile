#here add all stuff necessary to run redball demo in gazebo
#start from image passed by argument during build process.
ARG START_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"
ARG PROJECTS_DIR=/projects
ARG ROS2_WORKSPACE=ros2_ws

FROM $START_IMG as builder

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

# Args used as env variables always goes after FROM otherwise they are overridden
ARG PROJECTS_DIR
ARG ROS2_WORKSPACE

ARG CMAKE_EXTRA_OPTIONS=-j4

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT=1

WORKDIR /

# Install gazebo
RUN apt update && apt install -y \
    gazebo

RUN apt update && apt install -y \
    ros-humble-gazebo-msgs \
    ros-humble-gazebo-ros \
    ros-humble-moveit \
    ros-humble-moveit-visual-tools \
    ros-humble-ros2-controllers \
    ros-humble-moveit-ros-planning-interface

RUN echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> /usr/local/bin/setup_robotology_tdd.sh

# Install nlop (non-linear optimization needed for building trac_ik)
RUN bash -c "mkdir -p ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    git clone https://github.com/stevengj/nlopt.git &&\
    cd nlopt &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make &&\
    make install"

RUN bash -c "mkdir -p ${PROJECTS_DIR}/${ROS2_WORKSPACE}/src && cd ${PROJECTS_DIR}/${ROS2_WORKSPACE}/src &&\
    source /opt/ros/humble/setup.bash &&\
    git clone https://bitbucket.org/traclabs/trac_ik.git -b rolling-devel &&\
    cd trac_ik &&\
    colcon build &&\
    source install/setup.bash"

RUN bash -c "cd ${PROJECTS_DIR}/${ROS2_WORKSPACE}/src &&\
    source /opt/ros/humble/setup.bash &&\
    git clone https://github.com/icub-tech-iit/xcub-moveit2 &&\
    cd .. &&\
    colcon build &&\
    source install/setup.bash"

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["bash"]

