#here add all stuff necessary to run icub-tests
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_source
ARG SOURCE_IMG="none"
ARG PROJECTS_DIR="/home/icub/projects"
ARG INSTALL_DIR="/home/icub/install_dir"
ARG release="none"
ARG sbtag="none"
ARG METADATA_FILE=${INSTALL_DIR}/bin/setup_metadata.sh

FROM $SOURCE_IMG as superbuild_builder

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG PROJECTS_DIR
ARG CMAKE_GENERATOR
ARG BUILD_TYPE
ARG CMAKE_EXTRA_OPTIONS
ARG INSTALL_DIR
ARG release
ARG sbtag
ARG METADATA_FILE

ENV DEBIAN_FRONTEND=noninteractive

# Some other definitions
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4

RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    cd build &&\
    cmake .. \
    -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=ON \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON \
        # for enabling robometry
        -DROBOTOLOGY_ENABLE_DYNAMICS:BOOL=ON \ 
        -DYCM_USE_DEPRECATED:BOOL=OFF \
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DYCM_EP_INSTALL_DIR=${INSTALL_DIR} \
        -DENABLE_yarpmod_grabber:BOOL=ON \
        &&\
        # Build all the projects
        cmake --build . --target update-all -- ${CMAKE_EXTRA_OPTIONS} &&\
        cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

FROM scratch

ARG PROJECTS_DIR
ARG CMAKE_GENERATOR
ARG BUILD_TYPE
ARG CMAKE_EXTRA_OPTIONS
ARG INSTALL_DIR
ARG release
ARG sbtag
ARG METADATA_FILE
ARG metadata

COPY --from=superbuild_builder / /

# The bashrc is read only when opening an interactive shell. Let other projects find packages contained
# in the superbuild.
ENV CMAKE_PREFIX_PATH=${INSTALL_DIR}

ENV QT_X11_NO_MITSHM=1 
ENV YARP_COLORED_OUTPUT=1 

RUN echo "File metadata = ${METADATA_FILE}" &&\
    echo 'echo 'This images has release=$release and had been built with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

 
CMD ["bash"]
