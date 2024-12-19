#here add all stuff necessary to run icub-tests
#start from image passed by argument during build process. Usually it is icubteamcode/superbuild:master-unstable_source
ARG SOURCE_IMG="none"

ARG HOME_DIR=/home/icub
ARG PROJECTS_DIR=${HOME_DIR}/projects
ARG INSTALL_DIR=${PROJECTS_DIR}/robotology-superbuild/build/install
ARG release="master"
ARG sbtag="Stable"
ARG metadata="data"
ARG METADATA_FILE=${INSTALL_DIR}/bin/setup_metadata.sh
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh

# Define default user
ARG USERNAME=icub

FROM $SOURCE_IMG AS superbuild_builder

LABEL maintainer="valentina.gaggero@iit.it, jacopo.losi@iit.it"

ARG HOME_DIR
ARG PROJECTS_DIR
ARG CMAKE_GENERATOR
ARG BUILD_TYPE
ARG CMAKE_EXTRA_OPTIONS
ARG INSTALL_DIR
ARG release
ARG sbtag
ARG METADATA_FILE
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG USERNAME

ENV DEBIAN_FRONTEND=noninteractive

USER $USERNAME

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup.sh ${ROBOTOLOGY_INITIALIZATION_FILE}
RUN sudo chown -R icub: /usr/local/bin/entrypoint.sh
RUN sudo chown -R icub: /usr/local/bin/setup_robotology_tdd.sh

RUN git config --global user.email "icub@icub.it" &&\
    git config --global user.name "icub"

# Some other definitions
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG BUILD_TYPE=Release
ARG CMAKE_EXTRA_OPTIONS=-j4

RUN cd ${PROJECTS_DIR}/robotology-superbuild &&\
    cd build &&\
    cmake .. \
    -G "$CMAKE_GENERATOR" \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DNON_INTERACTIVE_BUILD:BOOL=OFF \
        -DROBOTOLOGY_ENABLE_CORE:BOOL=ON \
        -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON \
        -DYCM_EP_INSTALL_DIR=${INSTALL_DIR} \ 
        # for enabling robometry
        -DROBOTOLOGY_ENABLE_DYNAMICS:BOOL=ON \ 
        -DROBOTOLOGY_USES_GAZEBO=OFF \
        -DROBOTOLOGY_PROJECT_TAGS=${sbtag} \
        -DYCM_USE_CMAKE_PROPOSED=ON \
        &&\
        # Build all the projects
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
ARG ROBOTOLOGY_INITIALIZATION_FILE
ARG USERNAME

USER $USERNAME

COPY --from=superbuild_builder / /

# The bashrc is read only when opening an interactive shell. Let other projects find packages contained
# in the superbuild.
ENV CMAKE_PREFIX_PATH=${INSTALL_DIR}

ENV QT_X11_NO_MITSHM=1 
ENV YARP_COLORED_OUTPUT=1 

RUN echo 'echo 'This images has release=$release and is built with superbuild_tag=$sbtag. Metadata=$metadata ' '  >> $METADATA_FILE

RUN echo "source ${INSTALL_DIR}/share/robotology-superbuild/setup.sh" >>  $ROBOTOLOGY_INITIALIZATION_FILE
RUN echo "source ${METADATA_FILE}" >> $ROBOTOLOGY_INITIALIZATION_FILE

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["bash"]
