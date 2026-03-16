#!/bin/bash
source ~/.bashrc

export DEBUG=${DEBUG:-false}
export SSH_KEY_PATH=${SSH_KEY_PATH}
export LOAD_SSH_KEY=${LOAD_SSH_KEY:-false}


# SSH KEY
if [ "${LOAD_SSH_KEY}" == 'true' ] && [ -f "${SSH_KEY_PATH}" ];then
    eval "$(ssh-agent -s)"
    ssh-add "${SSH_KEY_PATH}"
fi

# True entry
if [ "${DEBUG}" == 'true' ];then
    /bin/bash
else
    /usr/local/bin/python3 -m pyanex.execute
fi