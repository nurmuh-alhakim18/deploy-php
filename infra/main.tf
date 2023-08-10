module "my-local-firewall" {
  source          = "./network"
  firewall_name   = "my-local-firewall"
  firewall_ports  = "8000"
}

module "my-http-firewall" {
  source = "./network"
  firewall_name = "my-http-firewall"
  firewall_ports = "80"
}

module "my-instance" {
  source           = "./instance"
  instance_name    = "my-instance"
  instance_zone    = "asia-southeast2-a"
  instance_network = "default"
  disk_size        = "30"
}