#!/bin/bash
set -e

if [ -z "$(which /usr/share/gazebo/setup.sh)" ] ; then
    echo "File source /usr/share/gazebo/setup.sh not found."
    exit 1
fi

source /usr/share/gazebo/setup.sh

echo "[ -r /usr/share/gazebo/setup.sh   ] && . /usr/share/gazebo/setup.sh" >> /root/.bashrc
echo "[ -r /usr/share/tmp.sh   ] && . /usr/share/tmp.sh" >> /root/.bashrc

# If a CMD is passed, execute it
exec "$@"
