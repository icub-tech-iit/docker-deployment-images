# Reference: https://github.com/utensils/docker-opengl/
# This dockerfile produces an image of ubuntu-focal plus a compiled mesa library with device dri disabled, in order to use rendering by software.
# In this way the producted image can be run on any pc.

ARG SOURCE_IMG="none"
ARG METADATA_FILE=/usr/local/bin/setup_metadata.sh
FROM $SOURCE_IMG as human_sensing

LABEL maintainer="laura.cavaliere@iit.it vadim.tikhanoff@iit.it" 

ARG METADATA_FILE

RUN apt-get update &&\
    apt-get install -y  bzip2 libpng-dev libjpeg-dev libblas-dev liblapack-dev libsqlite3-dev &&\
    apt-get install -y libprotobuf-dev protobuf-compiler &&\
    apt-get install -y libgoogle-glog-dev &&\
    apt-get install -y libhdf5-serial-dev libhdf5-dev &&\
    apt-get install -y libatlas3-base libatlas-base-dev liblapacke-dev &&\
    apt-get install -y libleveldb-dev libsnappy-dev &&\
    apt-get install -y --no-install-recommends libboost-all-dev &&\
    apt-get install -y wget &&\
    apt-get install -y gcc-8 &&\ 
    apt-get install -y g++-8

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 110 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8

RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git &&\
    cd openpose && git checkout tags/v1.7.0

RUN cd openpose &&\
    mkdir build &&\
    cd build &&\
    cmake .. \
        -D CUDNN_INCLUDE=/usr/include \
        -D CUDNN_LIBRARY=/usr/lib/x86_64-linux-gnu/ \
        -D CUDA_ARCH=Manual \
        -D CUDA_ARCH_BIN="35 37 50 52 53 60 61 62 70 72 75"\
    &&\
    make -j4 &&\
    make install
#-D CUDA_ARCH="Turing" -D BUILD_CAFFE=OFF -D Caffe_INCLUDE_DIRS=/usr/local/include/caffe -D Caffe_LIBS=/usr/local/lib/libcaffe.so 

RUN echo 'export openpose_ROOT=/openpose' >> /root/.bashrc 
ENV openpose_ROOT=/openpose

# we copy the models to the path expected by yarpOpenPose
RUN cd usr/local/src/ && mkdir robot && cd robot && mkdir openpose && cd openpose &&\
    cp -r /openpose/models .

RUN git clone https://github.com/robotology/human-sensing.git

RUN cd human-sensing/yarpOpenPose &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make install

RUN git clone https://github.com/davisking/dlib.git &&\
    cd dlib && git checkout tags/v19.22 &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    cmake --build . &&\
    make install

RUN cd human-sensing && \
    mkdir build &&\
    cd build &&\
    cmake .. \
         -DBUILD_FACELANDMARKS:BOOL=ON \
         -DDOWNLOAD_FACE_LANDMARKS_DAT=ON \ 
    &&\
    make install

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > ${METADATA_FILE}
RUN echo 'echo 'This image was built on $metadata ' '  >> ${METADATA_FILE}
