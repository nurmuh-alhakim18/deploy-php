# Add a firewall rule to allow HTTP (80), SSH (22), RDP (3389) and ICMP traffic on mynetwork
resource "google_compute_firewall" "my_firewall" {
  name = "my-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web-server"]
}

# Create the vm instance
module "my-instance" {
  source           = "./instance"
  instance_name    = "my-instance"
  instance_zone    = "asia-southeast2-a"
  instance_network = "default"
}