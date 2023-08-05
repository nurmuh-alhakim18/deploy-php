# Add a firewall rule to allow run on port 8000
resource "google_compute_firewall" "my_server_firewall" {
  name = "my-allow-server-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web-server"]
}

resource "google_compute_firewall" "my_allow_http_firewall" {
  name = "my-allow-http-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
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