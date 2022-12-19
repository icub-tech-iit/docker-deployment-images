#
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_devel_full
ARG SOURCE_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"

FROM alpine as model_data
RUN apk --no-cache --update-cache add wget
WORKDIR /data/patch_experts

RUN wget -q https://www.dropbox.com/s/7na5qsjzz8yfoer/cen_patches_0.25_of.dat &&\
    wget -q https://www.dropbox.com/s/k7bj804cyiu474t/cen_patches_0.35_of.dat &&\
    wget -q https://www.dropbox.com/s/ixt4vkbmxgab1iu/cen_patches_0.50_of.dat &&\
    wget -q https://www.dropbox.com/s/2t5t1sdpshzfhpj/cen_patches_1.00_of.dat

## ==================== Install Ubuntu Base libs ===========================
## This will be our base image for OpenFace, and also the base for the compiler
## image. We only need packages which are linked


#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
#ARG UBUNTU_IMG_NAME="icubteamcode/superbuild:v2020.05_sources"
FROM $SOURCE_IMG as ubuntu_base

ARG METADATA_FILE

LABEL maintainer="alexandre.gomespereira@iit.it, laura.cavaliere@iit.it, vadim.tikhanoff@iit.it" 

ARG DEBIAN_FRONTEND=noninteractive

# todo: minimize this even more
RUN apt-get update -y -qq &&\
    apt-get install -y -qq curl &&\
    apt-get install -y -qq --no-install-recommends \
        libopenblas-dev liblapack-dev \
        libavcodec-dev libavformat-dev libswscale-dev \
        libtbb2 libtbb-dev libjpeg-dev \
        libpng-dev libtiff-dev &&\
    rm -rf /var/lib/apt/lists/*

## ==================== Build-time dependency libs ======================
## This will build and install opencv and dlib into an additional dummy
## directory, /root/diff, so we can later copy in these artifacts,
## minimizing docker layer size
## Protip: ninja is faster than `make -j` and less likely to lock up system
#FROM ubuntu_base as cv_deps

WORKDIR /root/build-dep
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -qq -y \
        cmake ninja-build pkg-config build-essential checkinstall\
        g++-8 &&\
    rm -rf /var/lib/apt/lists/* &&\
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8

##        llvm clang-3.7 libc++-dev libc++abi-dev  \
## ==================== Building dlib ===========================

#RUN curl http://dlib.net/files/dlib-19.13.tar.bz2 -LO &&\
RUN wget http://dlib.net/files/dlib-19.13.tar.bz2 &&\
    tar xf dlib-19.13.tar.bz2 && \
    rm dlib-19.13.tar.bz2 &&\
    mv dlib-19.13 dlib &&\
    mkdir -p dlib/build &&\
    cd dlib/build &&\
    cmake -DCMAKE_BUILD_TYPE=Release -G Ninja .. &&\
    ninja && \
    ninja install && \
    DESTDIR=/root/diff ninja install &&\
    ldconfig

## ==================== Building OpenCV ======================
ENV OPENCV_VERSION=4.1.0

#RUN curl https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz -LO &&\
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz &&\
    tar xf ${OPENCV_VERSION}.tar.gz && \
    rm ${OPENCV_VERSION}.tar.gz &&\
    mv opencv-${OPENCV_VERSION} opencv && \
    mkdir -p opencv/build && \
    cd opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D WITH_TBB=ON -D WITH_CUDA=OFF \
        -DWITH_QT=OFF -DWITH_GTK=OFF\
        -G Ninja .. && \
    ninja && \
    ninja install && \
    DESTDIR=/root/diff ninja install

## ==================== Building OpenFace ===========================
#FROM cv_deps as openface

# todo: minimize this even more
RUN apt-get update -qq &&\
    apt-get install -qq curl &&\
    apt-get install -qq --no-install-recommends \
        git &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
# clone the openFace repository first
RUN git clone https://github.com/TadasBaltrusaitis/OpenFace.git openface #/root/openface/ 

# then we clone the yarpOpenFace repo, where we can find the updated CMakeLists.txt file
RUN git clone https://gitlab.iit.it/cognitiveInteraction/yarpopenface.git


COPY --from=model_data /data/patch_experts/* \
    /root/openface/lib/local/LandmarkDetector/model/patch_experts/

# copy the CMakeLists.txt into openface folder
RUN cp yarpopenface/CMakeLists.txt /root/openface

RUN cd openface && mkdir -p build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -G Ninja .. && \
    ninja && \
    DESTDIR=/root/diff ninja install


## ==================== Streamline container ===========================
## Clean up - start fresh and only copy in necessary stuff
## This shrinks the image from ~8 GB to ~1.6 GB
#FROM ubuntu_base as final

WORKDIR /root

# Copy in only necessary libraries
#COPY --from=openface /root/diff /

# Since we "imported" the build artifacts, we need to reconfigure ld
RUN ldconfig

# old configuration, now code is available on gitlab: https://gitlab.iit.it/cognitiveInteraction/yarpopenface.git
#COPY yarpOpenFace .
#COPY cmake .


RUN cd yarpopenface/yarpOpenFace &&\
    mkdir build &&\
    cd build &&\
    cmake -D CMAKE_CXX_STANDARD=14 \
          -D CMAKE_CXX_STANDARD_REQUIRED=ON \
          -D CMAKE_CXX_EXTENSIONS=OFF .. &&\
    make install 


ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > ${METADATA_FILE}
RUN echo 'echo 'This image was built on $metadata ' '  >> ${METADATA_FILE}