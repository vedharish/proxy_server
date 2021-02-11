terraform {
  backend "s3" {
    bucket  = "web-server-management-terraform"
    key     = "terraform/terraform_initial_user.tfstate"
    region  = "ap-south-1"
  }
}
