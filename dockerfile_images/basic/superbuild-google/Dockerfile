#here add all stuff necessary to run superbuild-google demo
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_devel_full
ARG SOURCE_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"


FROM $SOURCE_IMG as builder

LABEL maintainer="laura.cavaliere@iit.it, vadim.tikhanoff@iit.it"

# Install dependencies for the git projects
RUN apt-get update &&\
    apt-get install -y \
         # MISC
        bash-completion \
        git

# Install the projects using the superbuild (From Diego)

ARG METADATA_FILE
ARG PROJECTS_DIR=/projects
ARG BRANCH=master
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR="/usr/local/"

# the first cmake is to reconfigure cmake to find the newly installed portaudio libs
#RUN cd ${PROJECTS_DIR}/robotology-superbuild/build/src/YARP &&\
#    cmake . &&\
    #cmake . \
    #    -DENABLE_yarpmod_portaudio=ON \
    #    -DENABLE_yarpmod_portaudioPlayer=ON \
#        -DENABLE_yarpmod_portaudioRecorder=ON \
#        &&\
#    cmake --build . -- ${CMAKE_EXTRA_OPTIONS} &&\
#    make install

ENV DEBIAN_FRONTEND=noninteractive

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT=1
#ENV GOOGLE_APPLICATION_CREDENTIALS=/root/authorization/${FILE_INPUT} #This should be created in entrypoint as FILE_INPUT is not available yet at this level
ENV GOOGLEAPIS_GENS_PATH=/googleapis/gens


#COPY ./startaudio.ini /root/

# Pre-requisites before intalling grpc
RUN apt-get update &&\
    apt install -y curl gnupg &&\
    apt-get install -y autoconf &&\
    apt-get install -y libglib2.0-dev build-essential autoconf libtool pkg-config &&\
    # libgflags-dev is only required if building with make (deprecated)
    apt-get install -y libgflags-dev &&\
    apt-get install -y golang &&\
    apt-get install -y libc-ares-dev &&\
    apt-get install -y libssl-dev &&\
    # clang and LLVM C++ lib is only required for sanitizer builds
    apt-get install -y clang libc++-dev




RUN git clone -b v1.32.0 https://github.com/grpc/grpc.git &&\
    cd grpc &&\
    git submodule update --init &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make

RUN cd grpc/build &&\
    cmake .. -DgRPC_INSTALL=ON \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_BUILD_TYPE=Release \
            -DgRPC_BUILD_TESTS=OFF \
            -DgRPC_SSL_PROVIDER=package \
            -DgRPC_ZLIB_PROVIDER=package &&\
    make -j4 &&\
    make install



# Add the Cloud SDK distribution URI as a package source
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN apt-get install -y apt-transport-https ca-certificates gnupg

#Import the google cloud public key
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN apt-get update &&\
    apt-get install -y google-cloud-sdk

# The next line updates PATH for the Google Cloud SDK.
RUN if [ -f '/google-cloud-sdk/path.zsh.inc' ]; then . '/google-cloud-sdk/path.zsh.inc'; fi >> /root/.bashrc

# The next line enables shell command completion for gcloud.
RUN if [ -f '/google-cloud-sdk/completion.zsh.inc' ]; then . '/google-cloud-sdk/completion.zsh.inc'; fi >> /root/.bashrc

# Needed for speechInteraction
RUN git clone https://github.com/googleapis/googleapis.git &&\
    apt-get install -y python-dev python3-pip &&\
    apt-get install -y python3-dev &&\
    apt-get install -y default-jdk &&\
    cd googleapis &&\
    sed -i '36 i FLAGS+= --experimental_allow_proto3_optional' Makefile &&\
    make &&\
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN mkdir /root/authorization
# Copy the superbuild binary & entrypoint script from previous stage
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > $METADATA_FILE
RUN echo 'echo 'This image was built on $metadata ' '  >> $METADATA_FILE

CMD ["bash"]
