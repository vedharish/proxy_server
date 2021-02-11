#! /bin/bash

debug() {
  [ ${DEBUG} -gt 0 ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $@" 1>&2
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@"
}

aws_setup() {
  debug "Setting up AWS resources"

  cd $SCRIPT_PATH/provision/terraform
  terraform init
  terraform apply -auto-approve
}

initial_user_setup() {
  debug "Setting up user for running terraform"
  cd $SCRIPT_PATH/provision/terraform_initial_user
  terraform init
  terraform apply -auto-approve
}

setup_aws_credentials() {
  mkdir -p /root/.aws
  echo "[default]" > /root/.aws/credentials
  echo "aws_access_key_id = $ACCESS_KEY_ID" >> /root/.aws/credentials
  echo "aws_secret_access_key = $SECRET_ACCESS_KEY" >> /root/.aws/credentials
}

setup_terraform_state_bucket() {
  debug "Setting up terraform state file bucket"
  aws s3 ls s3://$AWS_STATE_FILE_BUCKET_NAME/ >/$DEV_NULL 2>&1
  if [ "$?" != "0" ]; then
    aws s3api create-bucket --bucket $AWS_STATE_FILE_BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
  fi
  aws s3 ls s3://$AWS_STATE_FILE_BUCKET_NAME/ >/$DEV_NULL 2>&1
  if [ "$?" != "0" ]; then
    log "[ERROR] Was not able to create / access terraform state file bucket. name: $AWS_STATE_FILE_BUCKET_NAME"
  fi
}

cleanup_aws_setup() {
  debug "Cleaning up AWS resources"

  cd $SCRIPT_PATH/provision/terraform_cleanup
  terraform init
  terraform apply -auto-approve
}
