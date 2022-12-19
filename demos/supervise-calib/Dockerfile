#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master_master-unstable_sources
ARG SOURCE_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"

FROM $SOURCE_IMG as builder

ARG METADATA_FILE

LABEL maintainer="laura.cavaliere@iit.it, valentina.vasco@iit.it, vadim.tikhanoff@iit.it"

ENV DEBIAN_FRONTEND=noninteractive

#The EXPOSE instruction does not actually publish the port.
#It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published.
#To actually publish the port when running the container, use the -p flag on docker run to publish and map one or more ports, or the -P flag to publish all exposed ports and map them to high-order ports.
EXPOSE 10000/tcp 10000/udp

# Some QT-Apps don't show controls without this
ENV QT_X11_NO_MITSHM 1
ENV YARP_COLORED_OUTPUT=1

RUN git clone https://github.com/opencv/opencv_contrib.git

RUN git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    mkdir build && cd build && \
    cmake ..  -DOPENCV_ENABLE_NONFREE=ON \
              -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules && \
    make install -j4


RUN git clone https://github.com/robotology/calibration-supervisor && \
    cd calibration-supervisor && \
    mkdir build && cd build && \
    cmake ..  -DSUPERVISE_REDBALL=OFF &&\
    make install -j4

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > ${METADATA_FILE}
RUN echo 'echo 'This image was built on $metadata ' '  >> ${METADATA_FILE}
CMD ["bash"]
