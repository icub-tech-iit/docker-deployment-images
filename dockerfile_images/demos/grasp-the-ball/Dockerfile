#here add all stuff necessary to run redball demo
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_devel_full
ARG SOURCE_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"
FROM $SOURCE_IMG as builder

LABEL maintainer="valentina.gaggero@iit.it, valentina.vasco@iit.it, laura.cavaliere@iit.it"

# Install the projects using the superbuild (From Diego)
ARG PROJECTS_DIR=/projects
ARG METADATA_FILE
ARG BRANCH=master
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR="/usr/local/"

RUN cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/icub-basic-demos && \
    cd icub-basic-demos && \
    mkdir build && cd build && \
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} &&\
    make install

RUN cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/calibration-supervisor.git && \
    cd calibration-supervisor && \
    mkdir build && cd build && \
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DSUPERVISE_CAMERA=OFF \
        &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} &&\
    make install


#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT=1

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}' > ${METADATA_FILE}
RUN echo 'echo 'This image was built on $metadata ' ' >> ${METADATA_FILE}


CMD ["bash"]

