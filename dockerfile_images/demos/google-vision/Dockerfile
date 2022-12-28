#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master_master-unstable_sources
ARG START_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh

FROM $START_IMG as builder

LABEL maintainer="laura.cavaliere@iit.it vadim.tikhanoff@iit.it" 

# Install the projects using the superbuild (From Diego)

ARG PROJECTS_DIR=/projects
ARG BRANCH=master
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR="/usr/local/"
ARG METADATA_FILE

ENV DEBIAN_FRONTEND=noninteractive

#The EXPOSE instruction does not actually publish the port. 
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published. 
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT=1
ENV PATH=/grpc/build:$PATH 
#ENV GOOGLE_APPLICATION_CREDENTIALS=/root/authorization/${FILE_INPUT} #This should be created in entrypoint as FILE_INPUT is not available yet at this level
ENV GOOGLEAPIS_GENS_PATH=/googleapis/gens
    
#git checkout on the branch will be removed as soon as the branch will be integrated in the human-sensing repo
RUN cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/human-sensing.git && \
    cd human-sensing/googleVisionAI && \
    mkdir build && cd build && \
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DBUILD_GOOGLE_VISION_AI=ON \
        -Dgoogleapis_INCLUDE_DIR=/googleapis/gens \
        &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} &&\
    make clean &&\
    make install

# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > $METADATA_FILE
RUN echo 'echo 'This image was built on $metadata ' '  >> $METADATA_FILE

CMD ["bash"]
