#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"

#FROM $START_IMG as builder

ARG ROS_IMG=ros:noetic-ros-core
# TODO Now it is working only with icub-main devel START_IMG IGNORED
ARG SUPERBUILD_IMG=icubteamcode/superbuild-icubhead:master-unstable_sources
ARG PROJECTS_DIR=/projects

FROM $SUPERBUILD_IMG as superbuild_builder
FROM $ROS_IMG as ros_builder

ENV DEBIAN_FRONTEND=noninteractive

LABEL maintainer="alexandre.gomespereira@iit.it, nicolo.genesio@iit.it, valentina.vasco@iit.it "

ARG PROJECTS_DIR

COPY --from=superbuild_builder ${PROJECTS_DIR} ${PROJECTS_DIR}
COPY --from=superbuild_builder /usr /usr
COPY --from=superbuild_builder /etc /etc

RUN apt update && apt install -y ros-noetic-rqt ros-noetic-rqt-common-plugins wget
RUN echo 'source "/opt/ros/$ROS_DISTRO/setup.bash"' >> /usr/local/bin/setup_robotology_tdd.sh

WORKDIR /root
RUN wget https://github.com/icub-tech-iit/appsAway/files/8919271/FT_setup.zip
RUN unzip FT_setup

RUN wget https://github.com/icub-tech-iit/appsAway/files/9112222/FT_setup_can.zip
RUN unzip FT_setup_can

# TODO Now it is working only with icub-main devel START_IMG IGNORED
RUN cd ${PROJECTS_DIR}/robotology-superbuild/build/src/ICUB &&\
    cmake . \
        -DENABLE_icubmod_canBusFtSensor:BOOL=ON \
        -DENABLE_icubmod_canBusAnalogSenor:BOOL=ON \
        -DENABLE_icubmod_embObjFTsensor:BOOL=ON \
        &&\
    make install -j5

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["bash"]
