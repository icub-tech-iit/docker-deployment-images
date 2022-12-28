#start from a nvidia with open gl on  ubuntu20.04 image
ARG START_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
FROM $START_IMG

ARG METADATA_FILE

LABEL maintainer="alexandre.gomespereira@iit.it, vadim.tikhanoff@iit.it, valentina.vasco@iit.it "

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y -qq \
      git \
      autoconf \
      automake \
      pkg-config \
      bison \
      build-essential \
      libexpat1-dev \
      flex \
      gettext \
      git \
      libglew-dev \
      libcheese8 \
      libcheese-gtk25 \
      libclutter-gst-3.0-0 \
      libcogl20 \
      libclutter-gtk-1.0-0 \
      libclutter-1.0-0 \
      xserver-xorg-input-all \
      libgl1-mesa-dri* \
      libtool \
      llvm-8 \
      llvm-8-dev \
      python-mako \
      xserver-xorg-dev \
      python-dev \
      libz-dev \
      libxext-dev \
      libx11-xcb-dev \
      libxcb-dri2-0-dev \
      libxcb-xfixes0-dev \
      wget \
      openssl \
      libssl-dev \
      nano \
      python3 \
      libpython3-dev
      

RUN set -xe; \
    mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    git clone https://gitlab.freedesktop.org/mesa/mesa.git;

RUN ln -s ../lib/llvm-7/bin/llvm-config /usr/bin/llvm-config

ARG MESA_VERSION=19.0.8
RUN set -xe; \
    cd /var/tmp/build/mesa; \
    git checkout mesa-${MESA_VERSION}; \
    libtoolize; \
    autoreconf --install; \
    ./configure \
        --enable-glx=gallium-xlib \
        --with-gallium-drivers=swrast,swr \
        --disable-dri \
        --disable-gbm \
        --disable-egl \
        --enable-gallium-osmesa \
        --enable-autotools \
        --enable-llvm \
        --with-llvm-prefix=/usr/lib/llvm-8/ \
        --prefix=/usr/local; \
    make -j$(getconf _NPROCESSORS_ONLN); \
    make install;

# Install runtime dependencies for Mesa
RUN set -xe; \
    apt-get update &&\
    apt-get install -y -qq \
        libexpat1 \
        #xdpyinfo \
        x11-utils \
        xvfb

ENV DEBIAN_FRONTEND=noninteractive

RUN wget https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3.tar.gz && \
    tar -zxvf cmake-3.17.3.tar.gz && \
    cd cmake-3.17.3 && \
    ./bootstrap && \
    make && \
    make install

#Some definitions
ARG PROJECTS_DIR=/projects
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR="/usr/local"
ARG release="master -b master_branch"
ARG sbtag="Stable"
#RUN if [ "$release" = "Stable" ]; then echo STABLE version is building; elif [ "$release" = "Ustable" ]; then echo UNSTABLE version is building && ${TAG}=Unstable; else echo SPECIFIC version $release is building && branch=$release; fi


RUN echo "DEBUG ==>  Release:" ${release} &&\
    echo "DEBUG ==>  TAG: " ${tag}

# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

RUN mkdir ${PROJECTS_DIR} && cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/robotology-superbuild.git &&\
    cd robotology-superbuild &&\
    git checkout ${release} &&\
    ./scripts/install_apt_dependencies.sh &&\
    rm -rf /var/lib/apt/lists/* &&\
    mkdir build && cd build &&\
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DYCM_USE_DEPRECATED:BOOL=OFF \
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DYCM_EP_INSTALL_DIR=${INSTALL_DIR} \
        -DROBOTOLOGY_USES_PYTHON=ON \
        &&\
    # Build all the projects
    cmake --build . --target update-all -- -j4 &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >> $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE

# Waiting https://github.com/robotology/robotology-superbuild/issues/95
RUN echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROBOTOLOGY_SUPERBUILD_INSTALL_PREFIX}/lib/rtf'  >> $ROBOTOLOGY_INITIALIZATION_FILE

# The bashrc is read only when opening an interactive shell. Let other projects find packages contained in the superbuild.
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
    cp ./checkRobotInterface /usr/local/bin

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT 1

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > $METADATA_FILE
RUN echo 'echo 'This images has release=$release and had been building with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE

CMD ["bash"]

