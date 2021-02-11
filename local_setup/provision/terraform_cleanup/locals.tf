locals {
  region = "ap-south-1"

  backend_bucket      = "web-server-management-terraform"
  account_id          = "357202274162"
  load_balancer_count = 3
  application_count   = 3
  key_pair_name       = "proxy_server_provisioner"
}
