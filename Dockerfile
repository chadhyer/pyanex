FROM python:3.14.3-alpine3.23

# Build args
ARG APP_VER='0'

# Create User
RUN addgroup \
        -g 1000 -S app \
    && adduser \
        -u 1000 \
        -s /usr/local/app/bin/python3.14 \
        -h /usr/local/app \
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
COPY --chown=app:app ./build/ "/usr/local/app/build/"
WORKDIR "/usr/local/app/build/"

## pip install A (stable)
RUN export PATH=$PATH:/usr/local/app/.local/bin \
    && pip3 install \
        build \
        ansible \
        --root-user-action=ignore

## Build and Install (volatile)
RUN sed -i -e "s|_BUILD_VERSION_|${APP_VER}|g" ./pyproject.toml \
    && python3 -m build \
    && pip3 install ./dist/pyanex-${APP_VER}*.tar.gz \
        --root-user-action=ignore

# APP
WORKDIR /usr/local/app/

## mkdir and ownership
RUN chown -R app:app /usr/local/app/ \
    && mkdir -p /usr/local/app/inventory/group_vars \
    && mkdir -p /usr/local/app/playbook/roles \
    && mkdir -p /usr/local/app/templates \
    && mkdir -p /usr/local/app/cache \
    && mkdir -p /usr/local/app/.ssh/ \
    && mkdir -p /usr/local/app/.secret \
    && chown -R app:app /usr/local/app/.ssh/ \
    && chown -R app:app /usr/local/app/.secret/

# # Setup Ansible (volatile)
COPY --chown=app:app ./ansible.cfg /usr/local/app/ansible.cfg

# user .bashrc changes (volatile)
RUN echo "alias ls='ls --color'" >> /usr/local/app/.bashrc \
    && echo "alias ll='ls --color -alF'" >> /usr/local/app/.bashrc \
    && echo 'PS1="\n\[\e[00;31m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[01;36m\]\h\[\e \[\e[00;37m\] \t \[\e[0m\]\[\e[01;35m\]\w\[\e[0m\]\[\e[01;37m\] \[\e[0m\]\n$ "' >> /usr/local/app//.bashrc

# Environment Vars
ENV ANSIBLE_CONFIG=/usr/local/app/ansible.cfg \
    INVENTORY_DIR=/usr/local/app/inventory \
    PLAYBOOK_DIR=/usr/local/app/playbook \
    KEY_DIR=/usr/local/app/.key

COPY --chown=app:app ./entrypoint.sh /usr/local/app/entrypoint.sh

USER app
ENTRYPOINT [ "/bin/bash", "/usr/local/app/entrypoint.sh" ]
