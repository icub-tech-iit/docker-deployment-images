#here add all stuff necessary to run speech demo
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_devel_full
ARG SOURCE_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh

FROM $SOURCE_IMG

LABEL maintainer="laura.cavaliere@iit.it, vadim.tikhanoff@iit.it" 

# Install the projects using the superbuild (From Diego)
ARG PROJECTS_DIR=/projects
ARG BRANCH=master
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j2
ARG INSTALL_DIR="/usr/local/"
ARG METADATA_FILE

ENV DEBIAN_FRONTEND=noninteractive

COPY ./startaudio.ini /root/

#Installing sound processing related tools and audio drivers linux
RUN apt-get update &&\
    apt-get install -y \
       sox \
       libsox-fmt-mp3 \
       alsa-base \
       alsa-utils \
       pulseaudio \
       portaudio19-dev \
       libportaudio2 \
       && \
    rm -rf /var/lib/apt/lists/* 
       
RUN cd ${PROJECTS_DIR} &&\
    git clone https://github.com/robotology/speech.git && \
    cd speech && \
    mkdir build && cd build && \
    cmake .. \
        -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DBUILD_GOOGLE_SPEECH=ON \
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
