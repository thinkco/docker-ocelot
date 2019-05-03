#!/usr/bin/env bash

# Get private IP address of running container.
# docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' consul-dev

DOCKER_NAME="consul-dev"
DOCKER_HOSTNAME="consul-dev"
DOCKER_IMAGE="consul"
DOCKER_PORTS="-p 8500:8500"

docker_start() {
    docker start $DOCKER_NAME 2>&1 >/dev/null
}

docker_stop() {
    docker stop $DOCKER_NAME 2>&1 >/dev/null
}

docker_rm() {
    docker rm $DOCKER_NAME 2>&1 >/dev/null
}

docker_create() {
    docker create $DOCKER_PORTS --name=$DOCKER_NAME -h $DOCKER_HOSTNAME $DOCKER_IMAGE agent -dev -ui -client=0.0.0.0 -bind='{{ GetPrivateIP }}' 2>&1 >/dev/null
}

startme() {
    if [ ! "$(docker ps | grep $DOCKER_NAME)" ]; then
        tput setaf 10
        echo "✅ [$DOCKER_NAME] starting."
        tput setaf 7
        docker_start
    else
        tput setaf 2
        echo "😅 [$DOCKER_NAME] already started."
        tput setaf 7
    fi
}

stopme() {
    if [ "$(docker ps | grep $DOCKER_NAME)" ]; then
        tput setaf 10
        echo "⛔ [$DOCKER_NAME] stopping."
        tput setaf 7
        docker_stop
    fi
}

cleanme() {
    if [ "$(docker ps -a | grep $DOCKER_NAME)" ]; then
        tput setaf 10
        echo "♻️  [$DOCKER_NAME] cleaning."
        tput setaf 7
        docker_rm
    else 
        tput setaf 2
        echo "😅 [$DOCKER_NAME] already squeaky clean."
        tput setaf 7
    fi
}

initme() {
    if [ ! "$(docker ps -a | grep $DOCKER_NAME)" ]; then
        tput setaf 10
        echo "⚡️ [$DOCKER_NAME] initializing."
        tput setaf 7
        docker_create
    fi
}

case "$1" in 
    start)   initme; startme ;;
    stop)    stopme ;;
    restart) stopme; startme ;;
    clean)   stopme; cleanme ;;
    *) echo "usage: $0 start|stop|restart|clean" >&2
       exit 1
       ;;
esac
