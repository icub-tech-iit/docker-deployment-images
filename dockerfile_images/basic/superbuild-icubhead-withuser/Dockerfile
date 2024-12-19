#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"

ARG HOME_DIR=/home/icub
ARG PROJECTS_DIR=${HOME_DIR}/projects
ARG INSTALL_DIR=${PROJECTS_DIR}/robotology-superbuild/build/install
ARG release="master"
ARG sbtag="Stable"
ARG metadata="data"
ARG METADATA_FILE=${INSTALL_DIR}/bin/setup_metadata.sh
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
ARG USERNAME=icub

FROM $START_IMG AS builder

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ENV DEBIAN_FRONTEND=noninteractive

ARG INSTALL_DIR
ARG PROJECTS_DIR
ARG release
ARG sbtag
ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE

# Define UID and GID
ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
 

# From here on all commands will be executed as $USERNAME user until FROM declaration
USER $USERNAME

RUN sudo mkdir -p /etc/bash_completion.d/ &&\
    sudo apt-get update &&\
    sudo apt-get install -y \
        # MISC
        bash-completion \
        git \
        vim \
        apt-transport-https \
        apt-utils

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}
RUN sudo chown -R icub: /usr/local/bin/entrypoint.sh
RUN sudo chown -R icub: /usr/local/bin/setup_robotology_tdd.sh

#Some definitions
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4

#ENV DEBIAN_FRONTEND=noninteractive is not sufficient
RUN echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections &&\
    mkdir ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/robotology-superbuild.git &&\
    cd robotology-superbuild &&\
    git checkout ${release} &&\
    sudo ./scripts/install_apt_dependencies.sh &&\
    mkdir build && cd build &&\
      cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DFETCHCONTENT_QUIET:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON \
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DYCM_USE_CMAKE_PROPOSED:BOOL=ON \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DFETCHCONTENT_QUIET:BOOL=ON \
       &&\
    #Build all the projects
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

FROM scratch

ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG release
ARG sbtag
ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG metadata
ARG USERNAME

USER $USERNAME

COPY --from=builder / /

# # The bashrc is read only when opening an interactive shell. Let other projects find packages contained
# # in the superbuild.
ENV CMAKE_PREFIX_PATH=${INSTALL_DIR}
# ENV YCM_EP_INSTALL_DIR=${INSTALL_DIR}

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM=1
ENV YARP_COLORED_OUTPUT=1

RUN echo 'echo 'This images has release=$release and is built with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["bash"]

