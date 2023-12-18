#!/bin/bash
set -e

if [ -z "$(which setup_robotology_tdd.sh)" ] ; then
    echo "File setup_robotology_tdd.sh not found."
    exit 1
fi

source setup_robotology_tdd.sh

echo "[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion" >> /root/.bashrc
echo "[ -r /usr/local/bin/setup_robotology_tdd.sh   ] && . /usr/local/bin/setup_robotology_tdd.sh" >> /root/.bashrc
echo "export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python3/dist-packages" >> /root/.bashrc

# If a CMD is passed, execute it
exec "$@"
