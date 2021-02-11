terraform {
  backend "s3" {
    bucket  = "web-server-management-terraform"
    key     = "terraform/terraform.tfstate"
    region  = "ap-south-1"
  }
}
