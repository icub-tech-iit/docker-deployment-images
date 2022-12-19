ARG START_IMG="none"
ARG PROJECTS_DIR=/projects
ARG INSTALL_DIR="/usr/local"
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
ARG GAZEBO_VER=11
ARG release="master"
ARG sbtag="Unstable"
ARG metadata="none"

    # Start from a ubuntu image plus mesa library recompiled with specific configuration
FROM $START_IMG AS builder

LABEL maintainer=" vadim.tikhanoff@iit.it, valentina.gaggero@iit.it, valentina.vasco@iit.it"

ENV DEBIAN_FRONTEND=noninteractive

    # Some definitions
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG SOURCES_BUILD_TYPE=RelWithDebInfo
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG BUILD_TYPE=Release
    # Variables defined before the first FROM can be accessed in all stages but they need to be re-declared
ARG GAZEBO_VER
ARG release
ARG sbtag
ARG PROJECTS_DIR
ARG INSTALL_DIR


    # Create a new runtimeusers group 
RUN groupadd -K GID_MIN=100 -K GID_MAX=499 runtimeusers
  
    # Install dependencies given in documentation in superbuild
RUN mkdir /etc/bash_completion.d/ && \
    # apt-get update and apt-get install should always be in the same layer to prevent caching errors
    apt-get update && \
    apt-get install -qq --no-install-recommends -y \
        software-properties-common \
        apt-transport-https \
        apt-utils \
        gpg-agent \
        dirmngr \
        bash-completion \
        git \
        wget \
        lsb-release \
        vim
    
    # Get gazebo from the osrf repo
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" \
        > /etc/apt/sources.list.d/gazebo-stable.list &&\
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - &&\
    apt-get update &&\
    apt install -y gazebo${GAZEBO_VER} libgazebo${GAZEBO_VER}-dev

RUN mkdir ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    # Clone relevant repos
    git clone https://github.com/robotology/robotology-superbuild.git &&\
    git clone https://github.com/robotology/cer.git &&\
    git clone https://github.com/robotology/cer-sim.git &&\
    git clone https://github.com/robotology/navigation.git &&\
    git clone https://github.com/icub-tech-iit/appsAway.git &&\
    git clone https://github.com/robotology/icub-models.git --depth 1 --branch devel &&\
    chmod -R g+rw ${PROJECTS_DIR}
    
    # Build robotology-superbuild
RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    git checkout ${release} &&\
    # Add no-install-recommends to robotology libraries
    awk '{if (/^xargs /) {$0=$0 " --no-install-recommends"}; print > "scripts/install_apt_dependencies.sh"}' scripts/install_apt_dependencies.sh && \
    ./scripts/install_apt_dependencies.sh &&\
    mkdir build && cd build &&\
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_DYNAMICS:BOOL=OFF \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DYCM_USE_DEPRECATED:BOOL=OFF \
        -DROBOTOLOGY_USES_GAZEBO=ON \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DYCM_EP_ADDITIONAL_CMAKE_ARGS:STRING="-DGAZEBO_YARP_PLUGINS_HAS_OPENCV=ON" \
        -DYCM_EP_INSTALL_DIR=${INSTALL_DIR} \
        &&\
    cmake --build . --target update-all -- ${CMAKE_EXTRA_OPTIONS} &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} &&\
    # Remove build directory
    rm -rf /projects/robotology-superbuild/build/src
    
    # Build checkRobotInterface
RUN cd ${PROJECTS_DIR}/appsAway/modules/checkRobotInterface && \ 
    mkdir build && cd build && \
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} && \
    cp ./checkRobotInterface /usr/local/bin && \
    # Remove build directory
    rm -rf ${PROJECTS_DIR}/appsAway/modules/checkRobotInterface/build 
    
    # Build icub-models
RUN cd ${PROJECTS_DIR}/icub-models && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=${SOURCES_BUILD_TYPE} && \
    make install && \
    # Remove build directory
    rm -rf ${PROJECTS_DIR}/icub-models/build 

    # Build CER
RUN cd ${PROJECTS_DIR}/cer && \
    git checkout devel &&\
    mkdir build && cd build &&\
    cmake .. \
    -G "$CMAKE_GENERATOR" \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -D ENABLE_cermod_cerDoubleLidar=ON \
    -DENABLE_faceExpressionImage=ON \
    -DGAZEBO_TRIPOD_PLUGIN=ON && \
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} 
    # Remove build directory
    # rm -rf ${PROJECTS_DIR}/cer/build
    
    # Build Navigation
RUN cd ${PROJECTS_DIR}/navigation && \
    mkdir build && cd build &&\
    cmake .. \
    -G "$CMAKE_GENERATOR" \
    &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} &&\
    make install && \
    rm -rf ${PROJECTS_DIR}/navigation/build

    # Using Multi-Stage Builds
    # We use a middle stage because several COPY commands with hardlinks and softlinks generate duplication
FROM $START_IMG as middlestage


    # Variables defined before the first FROM can be accessed in all stages but they need to be re-declared
ARG PROJECTS_DIR
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG INSTALL_DIR
ARG release
ARG sbtag
ARG metadata
ARG METADATA_FILE

    # Copy necessary files
COPY --from=builder ${PROJECTS_DIR}/ ${PROJECTS_DIR}
COPY --from=builder /usr/ /usr
COPY --from=builder /etc/ /etc

    # Copy entrypoint and setup
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >> $ROBOTOLOGY_INITIALIZATION_FILE && \
    echo "source ${METADATA_FILE}" >> ${ROBOTOLOGY_INITIALIZATION_FILE} && \
    echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROBOTOLOGY_SUPERBUILD_INSTALL_PREFIX}/lib/rtf'  >> $ROBOTOLOGY_INITIALIZATION_FILE && \
    echo 'export img_metadata=${metadata}'  > $METADATA_FILE && \
    echo 'echo 'This images has release=$release and had been building with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE

FROM scratch

    # Variables defined before the first FROM can be accessed in all stages but they need to be re-declared
ARG PROJECTS_DIR
ARG INSTALL_DIR
ARG GAZEBO_VER
ARG release
ARG sbtag
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG metadata

COPY --from=middlestage / /

ENV DEBIAN_FRONTEND=noninteractive 
ENV YARP_ROBOT_NAME="iCubGazeboV2_5" 
ENV GAZEBO_PLUGIN_PATH=/usr/local/lib:/usr/lib/x86_64-linux-gnu/gazebo-${GAZEBO_VER}/plugins 
ENV GAZEBO_MODEL_PATH=/usr/local/share/gazebo/models:/usr/local/share/iCub/robots:${PROJECTS_DIR}/cer-sim/gazebo 
ENV GAZEBO_MODEL_DATABASE_URI=http://gazebosim.org/models 
ENV GAZEBO_RESOURCE_PATH=/usr/local/share/gazebo/worlds 
ENV GAZEBO_MASTER_URI=http://localhost:11345 
ENV YARP_DATA_DIRS=${PROJECTS_DIR}/cer/build/share/CER:${PROJECTS_DIR}/cer/build/share/CER/robots/CER01:/usr/local/share/navigation 
ENV QT_X11_NO_MITSHM=1 
ENV YARP_COLORED_OUTPUT=1 
ENV img_metadata=${metadata}

EXPOSE 10000/tcp 10000/udp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["bash"]


