#!/bin/bash
set -e

if [ -z "$(which setup_robotology_tdd.sh)" ] ; then
    echo "File setup_robotology_tdd.sh not found."
    exit 1
fi

#needed for the first launch of the app. Seems that bashrc is not loaded upon run. 
export GOOGLE_APPLICATION_CREDENTIALS=/root/authorization/${FILE_INPUT}
gcloud auth activate-service-account --key-file=/root/authorization/${FILE_INPUT}

echo "[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion" >> /root/.bashrc
echo "[ -r /usr/local/bin/setup_robotology_tdd.sh   ] && . /usr/local/bin/setup_robotology_tdd.sh" >> /root/.bashrc

#needed for all subsequent runs eg: exec. 
echo "export GOOGLE_APPLICATION_CREDENTIALS=/root/authorization/${FILE_INPUT} " >> /root/.bashrc
echo "gcloud auth activate-service-account --key-file=/root/authorization/${FILE_INPUT} " >> /root/.bashrc

exec "$@"

