provider "aws" {
  region = local.region

  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/web_server_management"
  }
}
