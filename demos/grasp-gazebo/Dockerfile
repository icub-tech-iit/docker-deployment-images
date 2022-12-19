ARG START_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"
FROM $START_IMG

LABEL maintainer="vadim.tikhanoff@iit.it, alexandre.gomespereira@iit.it, laura.cavaliere@iit.it"

# Non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

ARG METADATA_FILE

# Create a new runtimeusers group
RUN groupadd -K GID_MIN=100 -K GID_MAX=499 runtimeusers

# Update apt database
RUN apt update

# Install essentials
RUN apt install -y apt-utils software-properties-common apt-transport-https sudo \
    psmisc lsb-release tmux nano wget curl telnet gnupg build-essential gdb git gitk \
    cmake cmake-curses-gui libedit-dev libxml2-dev autoconf locales gdebi terminator meld \
    dos2unix meshlab libqt5opengl5-dev mesa-utils xserver-xorg-video-all

# Set the locale
RUN locale-gen en_US.UTF-8

# Install python
RUN apt install -y python3 python3-dev python3-pip python3-setuptools && \
    python3 -m pip install pip && \
    python3 -m pip install setuptools

#  Deadsnakes PPA needed to install python in Ubuntu 20.04 (Focal). 
RUN add-apt-repository ppa:deadsnakes/ppa && \ 
    apt-get update

# RUN apt install -y python3.7 python3.7-dev && \
#     if [ ! -f "/usr/bin/python" ]; then ln -s /usr/bin/python3.7 /usr/bin/python; fi && \
#     python3 -m pip install pip && \
#     python3 -m pip install setuptools

# Install websockify
# RUN git clone https://github.com/novnc/websockify.git /opt/websockify && \
#     python --version && \
#     cd /opt/websockify && \
#     python3.7 setup.py install

# Install dependencies
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    wget https://packages.osrfoundation.org/gazebo.key -O - | apt-key add - && \
    apt update && \
    apt install -y libeigen3-dev build-essential cmake cmake-curses-gui coinor-libipopt-dev freeglut3-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev libtinyxml-dev libace-dev libedit-dev \
    libgsl0-dev libopencv-dev libode-dev liblua5.1-dev lua5.1 git swig qtbase5-dev qtdeclarative5-dev \
    qtmultimedia5-dev qml-module-qtquick2 qml-module-qtquick-window2 qml-module-qtmultimedia \
    qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qt-labs-folderlistmodel \
    qml-module-qt-labs-settings libsdl1.2-dev libxml2-dev libv4l-dev libcgal-dev \
    gazebo11 libgazebo11-dev

# Select options
ARG BRANCH=devel
ARG BUILD_TYPE=Release

# Install VTK
RUN git clone https://github.com/Kitware/VTK.git --depth 1 --branch v9.0.1 && \
    cd VTK && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DBUILD_TESTING=OFF && \
    make install && \
    cd ../.. && rm -Rf VTK

# Build ycm
RUN git clone https://github.com/robotology/ycm.git --depth 1 && \
    cd ycm && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf ycm

# Build yarp
RUN git clone https://github.com/robotology/yarp.git --depth 1 && \
    cp ./yarp/data/bash-completion/yarp /etc/bash_completion.d && \
    cd yarp && mkdir build && cd build && \
    cmake .. && make install && \
    cd ../.. && rm -Rf yarp

# Build icub-main
RUN git clone https://github.com/robotology/icub-main.git --depth 1 --branch $BRANCH && \
    cd icub-main && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DENABLE_icubmod_cartesiancontrollerserver=ON \
    -DENABLE_icubmod_cartesiancontrollerclient=ON \
    -DENABLE_icubmod_gazecontrollerclient=ON && \
    make install && \
    cd ../.. && rm -Rf icub-main

# Build gazebo-yarp-plugins #v3.5.0
ARG BRANCH_GAZEBO=devel 
RUN git clone https://github.com/robotology/gazebo-yarp-plugins.git --depth 1 --branch $BRANCH_GAZEBO && \
    cd gazebo-yarp-plugins && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf gazebo-yarp-plugins

# Clone icub-models #v1.17.0
ARG BRANCH_MODELS=devel 
RUN git clone https://github.com/robotology/icub-models.git --depth 1 --branch $BRANCH_MODELS && \
    cd icub-models && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf icub-models

# Build find-superquadric
RUN git clone https://github.com/robotology/find-superquadric.git --depth 1 && \
    cd find-superquadric && mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
    make install && \
    cd ../.. && rm -Rf find-superquadric

# Set environmental variables
ENV ICUBcontrib_DIR=/workspace/iCubContrib
ENV YARP_DATA_DIRS=/usr/local/share/yarp:/usr/local/share/iCub:${ICUBcontrib_DIR}/share/ICUBcontrib
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/yarp:${ICUBcontrib_DIR}/lib

# Install informative git for bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Set up .bashrc
WORKDIR /home

ENV GAZEBO_RESOURCE_PATH=${GAZEBO_RESOURCE_PATH}:${ICUBcontrib_DIR}/share/gazebo/worlds
ENV GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:/usr/local/share:/usr/local/share/iCub/robots:${ICUBcontrib_DIR}/share/gazebo/models
ENV PATH=${PATH}:${ICUBcontrib_DIR}/bin

RUN echo "GIT_PROMPT_ONLY_IN_REPO=1" >> ~/.bashrc && \
    echo "source \${HOME}/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc && \
    echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc && \
    echo "export GAZEBO_RESOURCE_PATH=\${GAZEBO_RESOURCE_PATH}:\${ICUBcontrib_DIR}/share/gazebo/worlds" >> ~/.bashrc && \
    echo "export GAZEBO_MODEL_PATH=\${GAZEBO_MODEL_PATH}:/usr/local/share:/usr/local/share/iCub/robots:\${ICUBcontrib_DIR}/share/gazebo/models" >> ~/.bashrc && \
    echo "export PATH=\${PATH}:\${ICUBcontrib_DIR}/bin" >> ~/.bashrc

# Set up script to prepare /workspace/iCubContrib
#COPY init-icubcontrib.sh /usr/bin/init-icubcontrib.sh
#COPY init-icubcontrib-local.sh /usr/bin/init-icubcontrib-local.sh
#RUN chmod +x /usr/bin/init-icubcontrib.sh /usr/bin/init-icubcontrib-local.sh

RUN mkdir -p /workspace/iCubContrib && \
    git clone https://github.com/robotology/icub-contrib-common.git --depth 1 /workspace/icub-contrib-common && \
    mkdir -p /workspace/icub-contrib-common/build && \
    cd /workspace/icub-contrib-common/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/workspace/iCubContrib && \
    make install && \
    rm -Rf /workspace/icub-contrib-common

#v1.3.0
ARG BRANCH_SANDBOX=devel 
RUN git clone https://github.com/robotology/icub-gazebo-grasping-sandbox.git /workspace/icub-gazebo-grasping-sandbox && \
    cd /workspace/icub-gazebo-grasping-sandbox && \
    mkdir build && cd build &&\
    cmake ../ &&\
    make install 

# Manage yarp port
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT 1


# Clean up unnecessary installation products
RUN rm -Rf /var/lib/apt/lists/*

COPY setup.sh /usr/share/gazebo/setup.sh
ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo "source ${METADATA_FILE}" >> /usr/share/gazebo/setup.sh
RUN echo 'export img_metadata=${metadata}'  > ${METADATA_FILE}
RUN echo 'echo 'This image was built on $metadata ' '  >> ${METADATA_FILE}
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Launch bash from /workspace
WORKDIR /workspace
CMD ["bash"]
