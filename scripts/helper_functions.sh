#! /bin/bash

source scripts/install_helpers.sh

debug() {
  [ ${DEBUG} -gt 0 ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $@" 1>&2
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@"
}

ensure_running_docker() {
	is_docker_daemon_running=$(ps aux | grep dockerd | grep -v grep)
	if [ -z "$is_docker_daemon_running" ]; then
		log "Docker daemon is not running; Attempting to start it"
		start_docker
	else
		debug "Docker daemon is running"
	fi
}

ensure_docker_compose() {
	which docker-compose >$DEV_NULL 2>$DEV_NULL
	if [ $? -ne 0 ]; then
    debug "docker-compose is not present. Installing"
		install_docker_compose
	fi
}

setup_env() {
  [ -f "$SCRIPT_PATH/local_setup/.env" ] && return
  echo NUM_WEB_LOADBALANCER_NODES=$NUM_WEB_LOADBALANCER_NODES > .env
  echo NUM_APPLICATION_SERVERS=$NUM_APPLICATION_SERVERS >> .env

  read -p "Please input your aws ACCESS_KEY_ID: " access_key_id
  read -p "Please input your aws SECRET_ACCESS_KEY: " secret_access_key

  log "Please note that these credentials will be present in local_setup/.env unencrypted" 

  echo ACCESS_KEY_ID=$access_key_id >> .env
  echo SECRET_ACCESS_KEY=$secret_access_key >> .env

  echo DEBUG=$DEBUG >> .env
}

print_usage() {
  log "Usage: provision_servers.sh action"
  log "supported actions: provision cleanup"
}

delete_folder() {
  if [ ! -d $1 ]; then
    return
  fi
  delete_count=$(find "$1" -type f | wc -l)
  if [ $delete_count -lt 100 ]; then
    debug "Deleting: $(find $1 -type f)"
    find $1 -type f -delete
  else
    log "Not deleting more than 99 files. Something is wrong"
    exit 1
  fi
  rmdir $1
}
