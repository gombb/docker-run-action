#!/usr/bin/env bash

if [ ! -z $INPUT_USERNAME ]; then
    echo $INPUT_PASSWORD | docker login $INPUT_REGISTRY -u $INPUT_USERNAME --password-stdin
fi

if [ ! -z $INPUT_DOCKER_NETWORK ]; then
    INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
fi

if [[ -n "${INPUT_CONTEXT_VARIABLES}" ]]; then
    set -a
    source <(echo -e "$INPUT_CONTEXT_VARIABLES" | jq -r 'to_entries|map("export \(.key)=\(.value|tostring|@sh)")|.[]')
    set +a;
fi    

exec docker run -v "/var/run/docker.sock":"/var/run/docker.sock" $INPUT_OPTIONS --entrypoint=$INPUT_SHELL $INPUT_IMAGE -c "${INPUT_RUN//$'\n'/;}"
