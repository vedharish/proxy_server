#! /bin/bash

: ${DEBUG:=0}
: ${TMP_PATH:=/tmp/}
: ${DEV_NULL:=/dev/null}
: ${LOG_PATH:=logs/}
: ${NUM_WEB_LOADBALANCER_NODES:=1}
: ${NUM_APPLICATION_SERVERS:=2}

if [ "$(whoami)" = "root" ]; then
  echo "Please do not run this script as root"
  exit 1
fi

SCRIPT_PATH=$(pwd)
BIN_PATH=$SCRIPT_PATH/bin
PATH=$PATH:$BIN_PATH

DOCKER_BINARY_PID_FILE=$SCRIPT_PATH/.docker_binary_pid

source scripts/helper_functions.sh

provision_resources() {
  [ ! -d $BIN_PATH ] && mkdir $BIN_PATH
  [ ! -d $LOG_PATH ] && mkdir $LOG_PATH

  ensure_running_docker
  ensure_docker_compose

  log "docker / docker-compose setup looks good. Going ahead"

  pushd . >$DEV_NULL
  cd local_setup
  setup_env
  docker-compose up --build
  popd >$DEV_NULL
}

cleanup_resources() {
  if [ -f $DOCKER_BINARY_PID_FILE ]; then
    log "Killing the spawned dockerd process. Please allow sudo"
    process_pid=$(cat $DOCKER_BINARY_PID_FILE)
    debug "Killing process: pid: $process_pid command: $(ps -p $process_pid -o command --no-headers)"
    sudo kill $process_pid
    rm $DOCKER_BINARY_PID_FILE
  fi
  delete_folder $LOG_PATH
  delete_folder $BIN_PATH
  [ -f local_setup/.env ] && rm local_setup/.env
}

if [ "$#" -ne 1 ]; then
  print_usage && exit 1
else
  if [ "$1" = "provision" ]; then
    debug "provisioning resources"
    ACTION=provision
  elif [ "$1" = "cleanup" ]; then
    debug "cleaning resources"
    ACTION=cleanup
  else
    log "Action $1 is not supported"
    print_usage && exit 1
  fi
fi

if [ "$ACTION" = "provision" ]; then
  provision_resources
elif [ "$ACTION" = "cleanup" ]; then
  cleanup_resources
fi
