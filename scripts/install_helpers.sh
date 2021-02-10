#! /bin/bash

check_systemctl_present() {
  which systemctl >$DEV_NULL 2>$DEV_NULL
  if [ $? -eq 0 ]; then
    debug "systemctl found in path"
    return 0
  else
    debug "systemctl not found in path"
    return 1
  fi
}

check_docker_unit_present() {
  check_systemctl_present
  is_systemctl_present=$?

  [ "$is_systemctl_present" = "1" ] && return 1

	if [ $(systemctl list-unit-files "docker.service" | wc -l) -gt 3 ]; then
		debug "docker unit found in systemctl"
    return 0
	else
		debug "docker was not found in systemctl list-unit-files."
    return 1
	fi
}

try_systemctl_start() {
	log "Attempting to start docker daemon via systemctl. Please allow sudo"
	sudo systemctl start docker

  return $?
}

try_starting_docker() {
  check_docker_unit_present
  is_docker_unit_file_present=$?
	
	if [ "$is_docker_unit_file_present" = "0" ]; then
    try_systemctl_start
    return $?
	else
		debug "Failed starting service"
    return 1
	fi
}

install_docker() {
  set -e

  debug "Installing docker binaries to bin path $BIN_PATH"
  if [ ! -f "$TMP_PATH/docker-20.10.3.tgz" ]; then
		wget -q https://download.docker.com/linux/static/stable/$(uname -m)/docker-20.10.3.tgz -O $TMP_PATH/docker-20.10.3.tgz
  fi
	pushd . >$DEV_NULL
	cd $TMP_PATH
  tar xzvf docker-20.10.3.tgz >$DEV_NULL
  mv docker/* $BIN_PATH/
  rmdir docker
  rm $TMP_PATH/docker-20.10.3.tgz
  popd >$DEV_NULL

  set +e
}

install_docker_compose() {
  wget -q "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o $BIN_PATH/docker-compose
  chmod a+x $BIN_PATH/docker-compose
}

start_installed_docker() {
	log "Starting dockerd process. Please allow sudo"
  sudo dockerd >$LOG_PATH/dockerd.log 2>$LOG_PATH/dockerd.err.log &
  echo $! > $DOCKER_BINARY_PID_FILE
}

start_docker() {
  try_starting_docker
  did_docker_start=$?

  if [ "$did_docker_start" = 0 ]; then
    debug "Docker Started"
  else
    debug "Installing docker"
    install_docker
    start_installed_docker
  fi
}
