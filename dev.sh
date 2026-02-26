#!/bin/bash
i='pyanex'
tag=$1
if [ -z "${tag}" ];then
    tag="$(docker images|grep $i|head -n 1|grep -Po ':\K.*? ')"
    echo ${tag}
fi
docker run --rm -it \
    --name $i-dev \
    --env-file ./default.env \
    --user "${USERID:-1001}:${GROUPID:-$USERID}" \
    --entrypoint /bin/bash \
    $i:${tag}

    # --net=host \
    # --volume ./build/src/pyae:/usr/local/lib/python3.10/site-packages/pyae \
    # --volume ./ansible/playbook:/usr/local/app/playbook \
    # --volume ./ansible/inventory:/usr/local/app/inventory \
    # --volume ./ansible/cache:/usr/local/app/cache \
    # --volume ./ansible/templates:/usr/local/app/templates \
    # --volume ./ansible/.secret:/usr/local/app/.secret \
    # --volume ./ansible/.key:/usr/local/app/.key \
    # --volume ~/.ssh/:/usr/local/app/.ssh/ \
