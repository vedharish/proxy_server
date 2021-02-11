#! /bin/bash

: ${DEBUG:=0}
: ${DEV_NULL:=/dev/null}
: ${AWS_REGION:=ap-south-1}
: ${AWS_STATE_FILE_BUCKET_NAME:=web-server-management-terraform}

SCRIPT_PATH=$(pwd)

source $SCRIPT_PATH/scripts/helper_functions.sh

setup_aws_credentials
setup_terraform_state_bucket
initial_user_setup
aws_setup

# cleanup_aws_setup
