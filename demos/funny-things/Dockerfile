#start from image passed by argument during build process. Usually it is an ubuntu image plus mesa library.
ARG START_IMG="none"
ARG METADATA_FILE="/usr/local/bin/setup_metadata.sh"
FROM $START_IMG

ARG METADATA_FILE

LABEL maintainer="german.rodriguez@iit.it, vadim.tikhanoff@iit.it"

ENV DEBIAN_FRONTEND=noninteractive

ARG BRANCH=master

RUN mkdir /root/shared-files

RUN apt update && \
    apt install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_17.x | bash - && \
    apt install -y nodejs fuse luarocks

RUN luarocks install luaposix

RUN npm install -g npm@latest

ARG PROJECTS_DIR=/projects
ARG CMAKE_EXTRA_OPTIONS=-j2

RUN cd ${PROJECTS_DIR}/robotology-superbuild/build &&\
    cmake .. \
    -DROBOTOLOGY_ENABLE_ICUB_BASIC_DEMOS:BOOL=ON \
    -DROBOTOLOGY_USES_LUA:BOOL=ON \
     &&\
    cmake --build . -- ${CMAKE_EXTRA_OPTIONS}

RUN cd ${PROJECTS_DIR}/robotology-superbuild/build/src/funny-things && \
    cmake . -DCREATE_FUNNYTHINGSAPP:BOOL=ON && \
    cmake --build . --target install

RUN export LUA_CPATH=";/usr/local/lib/lua/5.2/?.so"
RUN export LUA_PATH=";;;/usr/local/share/lua/5.2/posix/?.lua"

# Setup entrypoint
ARG ROBOTOLOGY_INITIALIZATION_FILE=/usr/local/bin/setup_robotology_tdd.sh

ARG metadata="none"

ENV img_metadata=${metadata}

RUN echo 'export img_metadata=${metadata}'  > $METADATA_FILE
RUN echo 'echo 'This image was built on $metadata ' '  >> $METADATA_FILE
CMD ["bash"]
