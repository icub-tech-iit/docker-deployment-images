#!/bin/bash
set -e

echo "[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion" >> /root/.bashrc

if [ -z "$(which /usr/share/gazebo/setup.sh)" ] ; then
    echo "File source /usr/share/gazebo/setup.sh not found."
    exit 1
fi

source /usr/share/gazebo/setup.sh

echo "[ -r /usr/share/gazebo/setup.sh   ] && . /usr/share/gazebo/setup.sh" >> /root/.bashrc

# If a CMD is passed, execute it
exec "$@"
