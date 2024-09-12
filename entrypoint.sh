#!/usr/bin/env bash

if [ ! -z $INPUT_USERNAME ]; then
    echo $INPUT_PASSWORD | docker login $INPUT_REGISTRY -u $INPUT_USERNAME --password-stdin
fi

if [ ! -z $INPUT_DOCKER_NETWORK ]; then
    INPUT_OPTIONS="$INPUT_OPTIONS --network $INPUT_DOCKER_NETWORK"
fi

if [[ -n "${INPUT_CONTEXT_VARIABLES}" ]]; then
    while IFS="=" read -r key value; do
        INPUT_OPTIONS="$INPUT_OPTIONS -e $key=$value"
        echo DONE $key
    done < <(echo "$INPUT_CONTEXT_VARIABLES" | jq -r 'to_entries|map("\(.key)=\(.value|tostring|@sh)")|.[]')
fi
echo $INPUT_OPTIONS
# exec docker run -v "/var/run/docker.sock":"/var/run/docker.sock" $INPUT_OPTIONS $INPUT_IMAGE --entrypoint=$INPUT_SHELL -c "${INPUT_RUN//$'\n'/;}"
# eval docker run -v "/var/run/docker.sock":"/var/run/docker.sock" $INPUT_OPTIONS $INPUT_IMAGE
DOCKER_CMD="docker run -v /var/run/docker.sock:/var/run/docker.sock $INPUT_OPTIONS"

if [ -n "$INPUT_RUN" ]; then
        DOCKER_CMD="$DOCKER_CMD --entrypoint=$INPUT_SHELL"
    DOCKER_CMD="$DOCKER_CMD $INPUT_IMAGE -c \"${INPUT_RUN//$'\n'/;}\""
else
    DOCKER_CMD="$DOCKER_CMD $INPUT_IMAGE"
fi

eval $DOCKER_CMD
