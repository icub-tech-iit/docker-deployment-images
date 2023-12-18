#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"

ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"
ARG PROJECTS_DIR=/projects
ARG INSTALL_DIR=${PROJECTS_DIR}/robotology-superbuild/build/install
ARG release="master"
ARG sbtag="Stable"
ARG METADATA_FILE=${INSTALL_DIR}/bin/setup_metadata.sh
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh

FROM $START_IMG AS builder

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG METADATA_FILE
ARG INSTALL_DIR
ARG PROJECTS_DIR
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4
ARG release
ARG sbtag
ARG metadata

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies given in documentation in superbuild
# https://github.com/robotology/robotology-superbuild#linux
RUN mkdir -p /etc/bash_completion.d/ && \
    apt-get update &&\
    apt-get install -y -qq --no-install-recommends\
        # MISC
        bash-completion \
        git \
        wget \
        apt-transport-https \
        ca-certificates \
        vim &&\
    update-ca-certificates

# Print debug info to check if relevant build args are taken correctly from conf_build.ini
RUN echo "DEBUG ==>  Release:" ${release} &&\
    echo "DEBUG ==>  TAG:" ${sbtag} &&\
    echo "DEBUG ==>  metadata:" ${metadata} &&\
    echo "DEBUG ==>  METADATA_FILE:" ${METADATA_FILE} &&\
    echo "DEBUG ==>  INSTALL_DIR:" ${INSTALL_DIR}

# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}

# The bashrc is read only when opening an interactive shell. Let other projects find packages contained in the superbuild.
ENV CMAKE_PREFIX_PATH=${INSTALL_DIR}

RUN mkdir ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/robotology-superbuild.git &&\
    cd robotology-superbuild &&\
    git checkout ${release} &&\
    ./scripts/install_apt_dependencies.sh &&\
    mkdir build && cd build &&\
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DYCM_USE_DEPRECATED:BOOL=OFF \
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        &&\
    # Build all the projects
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}
    
# This steps should theoretically help cleaning unecessary post-build files that are already installed and that can be eventually re-generated
RUN rm -rf ${PROJECTS_DIR}/robotology-superbuild/build/src &&\
    echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >> $ROBOTOLOGY_INITIALIZATION_FILE

# Stage 2: secondstage stage
FROM $START_IMG  AS secondstage

# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE

ARG PROJECTS_DIR
ARG METADATA_FILE
ARG release
ARG sbtag
ARG metadata

COPY --from=builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=builder /usr /usr
COPY --from=builder /etc /etc

RUN echo 'export img_metadata=${metadata}'  > ${METADATA_FILE}  &&\
    echo 'echo 'This images has release=$release and had been building with superbuild_tag=$sbtag. Metadata=$metadata' '  >> ${METADATA_FILE} &&\
    echo "source ${METADATA_FILE}" >> ${ROBOTOLOGY_INITIALIZATION_FILE}

# This should theoretically help reducing the size of the final image
FROM scratch

ARG metadata

COPY --from=secondstage / /

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM=1
ENV YARP_COLORED_OUTPUT=1

ENV img_metadata=${metadata}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["bash"]
