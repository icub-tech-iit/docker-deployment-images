#here add all stuff necessary to run icub-tests
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_source
ARG SOURCE_IMG="none"
ARG INSTALL_DIR="/usr/local"
#ARG PROJECTS_DIR=/projects
ARG release="master"
ARG sbtag="Stable"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"

FROM $SOURCE_IMG as builder

LABEL maintainer="valentina.gaggero@iit.it"



ARG PROJECTS_DIR=/projects
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR="/usr/local/"
ARG release
ARG sbtag
ARG METADATA_FILE

ENV DEBIAN_FRONTEND=noninteractive

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp 
#is necessary to expose port??

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT=1

# Dependencies for gnuplot
RUN apt update && \
    apt install -y python3 libglib2.0-dev-bin &&\
    apt install -y qtbase5-dev qtbase5-dev-tools libqt5svg5-dev qttools5-dev-tools &&\
    apt install -y gnuplot

RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    cd build &&\
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ROBOT_TESTING:BOOL=ON \
#        -DYCM_USE_DEPRECATED:BOOL=OFF \ because deprecated
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DYCM_EP_INSTALL_DIR=${INSTALL_DIR} \
        &&\
        # Build all the projects
        cmake --build . --target update-all -- -j4 &&\
        cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > $METADATA_FILE
RUN echo 'echo 'This image was built on $metadata ' '  >> $METADATA_FILE

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

 
CMD ["bash"]
