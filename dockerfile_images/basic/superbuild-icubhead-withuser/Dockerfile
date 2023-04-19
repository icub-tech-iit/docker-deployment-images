#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"

FROM $START_IMG

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=icub
ARG USER_UID=1000
ARG USER_GID=$USER_UID


RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
 

USER $USERNAME

RUN sudo mkdir /etc/bash_completion.d/ &&\
    sudo apt-get install -y \
        # MISC
        bash-completion \
        git \
        vim \
        apt-utils


#Some definitions
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR=/home/icub/install_dir
ARG release="master"
ARG sbtag="Stable"
ARG METADATA_FILE=/home/icub/install_dir/bin/setup_metadata.sh


# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}
RUN sudo chown -R icub: /usr/local/bin/entrypoint.sh
RUN sudo chown -R icub: /usr/local/bin/setup_robotology_tdd.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]


ARG PROJECTS_DIR=/home/icub/projects

#ENV DEBIAN_FRONTEND=noninteractive is not sufficient
RUN echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections &&\
    mkdir ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/robotology-superbuild.git &&\
    cd robotology-superbuild &&\
    git checkout ${release} -b ${release}_branch &&\
    sudo ./scripts/install_apt_dependencies.sh &&\
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
    #Build all the projects &&\
    cmake --build . --target update-all -- -j4 &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}


 RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  $ROBOTOLOGY_INITIALIZATION_FILE
 RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE

# # The bashrc is read only when opening an interactive shell. Let other projects find packages contained
# # in the superbuild.
 ENV CMAKE_PREFIX_PATH=${INSTALL_DIR}

#add checkRobotInterface
RUN cd ${PROJECTS_DIR} &&\
    git clone https://github.com/icub-tech-iit/appsAway.git && \
    cd  appsAway/modules/checkRobotInterface && \
    mkdir build && cd build && \
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} && \
    cp ./checkRobotInterface /home/icub/install_dir/bin



#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT 1



ARG metadata="none"

ENV img_metadata=${metadata}
RUN echo "File metadata = ${METADATA_FILE}"
RUN echo 'export img_metadata=${metadata}'  >> $METADATA_FILE
RUN echo 'echo 'This images has release=$release and had been building with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE


CMD ["bash"]

