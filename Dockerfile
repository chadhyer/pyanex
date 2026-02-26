FROM python:3.14.3-alpine3.23

# Create User
ENV APP_DIR=/usr/local/app
RUN addgroup \
        -g 1001 -S app \
    && adduser \
        -u 1001 \
        -s /usr/local/bin/python3.14 \
        -h /usr/local \
        -S app -G app

# Update
RUN apk update && apk upgrade
RUN apk add \
    unzip \
    bash \
    vim \
    openssh-client
RUN pip3 install --upgrade pip --root-user-action=ignore

# Build
COPY --chown=app:app ./build/ "${APP_DIR}/build/"
WORKDIR "${APP_DIR}/build/"

## pip install A (stable)
RUN export PATH=$PATH:${APP_DIR}/.local/bin \
    && pip3 install \
        build \
        ansible \
        --root-user-action=ignore

## Build and Install (volatile)
ENV BUILD_VERSION='0'
RUN sed -i -e "s|_BUILD_VERSION_|${BUILD_VERSION}|g" ./pyproject.toml \
    && python3 -m build \
    && pip3 install ./dist/pyanex-${BUILD_VERSION}*.tar.gz \
        --root-user-action=ignore

# APP
WORKDIR ${APP_DIR}

## mkdir and ownership
RUN chown -R app:app ${APP_DIR} \
    && mkdir -p ${APP_DIR}/inventory/group_vars \
    && mkdir -p ${APP_DIR}/playbook/roles \
    && mkdir -p ${APP_DIR}/templates \
    && mkdir -p ${APP_DIR}/cache \
    && mkdir -p ${APP_DIR}/.ssh/ \
    && mkdir -p ${APP_DIR}/.secret \
    && chown -R app:app ${APP_DIR}/.ssh/ \
    && chown -R app:app ${APP_DIR}/.secret/

# # Setup Ansible (volatile)
ENV ANSIBLE_CONFIG=${APP_DIR}/ansible.cfg
COPY --chown=app:app ./ansible.cfg ${APP_DIR}/ansible.cfg

# user .bashrc changes (volatile)
RUN echo "alias ls='ls --color'" >> ${APP_DIR}/.bashrc \
    && echo "alias ll='ls --color -alF'" >> ${APP_DIR}/.bashrc \
    && echo 'PS1="\n\[\e[00;31m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e\
[01;36m\]\h\[\e[0m\]\[\e[00;37m\] \t \[\e[0m\]\[\e[01;35m\]\w\[\e[0m\]\[\e\
[01;37m\] \[\e[0m\]\n$ "' >> ${APP_DIR}/.bashrc

USER app
ENTRYPOINT [ "/usr/local/bin/python3", "-m", "pyae.execute" ]
