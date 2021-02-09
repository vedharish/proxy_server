#! /bin/bash

source ./install_helpers.sh

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
		install_docker_compose
	fi
}
