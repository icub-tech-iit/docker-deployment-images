#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
ARG INSTALL_DIR=/usr/local
ARG PROJECTS_DIR=/projects
ARG release="none"
ARG sbtag="none"
ARG metadata="none"

FROM $START_IMG AS builder

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ENV DEBIAN_FRONTEND=noninteractive

ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG release
ARG sbtag
ARG metadata

# Some stage specific definitions
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4

# Install dependencies given in documentation in superbuild
# https://github.com/robotology/robotology-superbuild#linux
RUN mkdir /etc/bash_completion.d/ &&\
    apt-get update &&\
    apt-get install -y \
        # MISC
        bash-completion \
        git


# Setup entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}

RUN mkdir ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/robotology-superbuild.git &&\
    cd robotology-superbuild &&\
    git checkout ${release} -b ${release}_branch &&\
    ./scripts/install_apt_dependencies.sh &&\
    mkdir build && cd build &&\
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_DYNAMICS:BOOL=ON \
        -DYCM_USE_DEPRECATED:BOOL=OFF \
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DYCM_EP_INSTALL_DIR=${INSTALL_DIR} \
        -DENABLE_yarpmod_grabber:BOOL=ON \
        &&\
    # Build all the projects
    cmake --build . --target update-all -- -j4 &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

# Executing commands in chain makes compilation faster
# other then calling the command RUN everytime
RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >> $ROBOTOLOGY_INITIALIZATION_FILE &&\
    echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE

# Stage 2: secondstage stage
FROM $START_IMG AS secondstage

ARG PROJECTS_DIR
ARG INSTALL_DIR

COPY --from=builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=builder /usr /usr
COPY --from=builder /etc /etc

# The bashrc is read only when opening an interactive shell. Let other projects find packages contained
# in the superbuild.
ENV CMAKE_PREFIX_PATH=${INSTALL_DIR}

# This should theoretically help reducing the size of the final image
FROM scratch
COPY --from=secondstage / /

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT 1

ARG METADATA_FILE
ARG release
ARG sbtag
ARG metadata

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > $METADATA_FILE &&\
    echo 'echo 'This images has release=$release and had been building with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["bash"]

