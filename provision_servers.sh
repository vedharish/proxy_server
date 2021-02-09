#! /bin/bash

: ${DEBUG:=0}
: ${TMP_PATH:=/tmp/}
: ${DEV_NULL:=/dev/null}

if [ "$(whoami)" = "root" ]; then
  echo "Please do not run this script as root"
  exit 1
fi

SCRIPT_PATH=$(pwd)
BIN_PATH=$SCRIPT_PATH/bin
PATH=$PATH:$BIN_PATH

[ ! -d $BIN_PATH ] && mkdir $BIN_PATH
source scripts/helper_functions.sh

ensure_running_docker
ensure_docker_compose
