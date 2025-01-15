#here add all stuff necessary to run icub-tests
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_source
ARG SOURCE_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
ARG PROJECTS_DIR=/projects
ARG INSTALL_DIR=${PROJECTS_DIR}/robotology-superbuild/build/install
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
# Default tags
ARG release="master"  
ARG sbtag="Stable"
ARG metadata="data"

# Stage 1: build stage
FROM $SOURCE_IMG AS builder

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG METADATA_FILE
ARG INSTALL_DIR
ARG PROJECTS_DIR
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG release
ARG sbtag
ARG metadata

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}

ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4

ENV DEBIAN_FRONTEND=noninteractive

# Dependencies for gnuplot
RUN apt update && \
    apt install -y python3 libglib2.0-dev-bin &&\
    apt install -y qtbase5-dev qtbase5-dev-tools libqt5svg5-dev qttools5-dev-tools &&\
    apt install -y gnuplot

RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    cd build &&\
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DBUILD_TESTING:BOOL=ON \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ROBOT_TESTING:BOOL=ON \
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        &&\
        # Build all the projects
        cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  $ROBOTOLOGY_INITIALIZATION_FILE
# Stage 2: scratch stage
# This should theoretically help reducing the size of the final image
FROM scratch
COPY --from=builder / /

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp 
#is necessary to expose port??

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM=1
ENV YARP_COLORED_OUTPUT=1

ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE

RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

 
CMD ["bash"]
