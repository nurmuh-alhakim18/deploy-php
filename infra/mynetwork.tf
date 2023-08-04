resource "google_compute_network" "my_network" {
  name = "my-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "my_subnet_01" {
  name = "my-subnet-01"
  ip_cidr_range = "10.100.0.0/16"
  region = "asia-southeast2"
  network = google_compute_network.my_network.id
}

# Add a firewall rule to allow HTTP (80), SSH (22), RDP (3389) and ICMP traffic on mynetwork
resource "google_compute_firewall" "my_firewall" {
  name = "my-firewall"
  network = google_compute_network.my_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }

  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# Create the vm instance
module "mynet-id" {
  source           = "./instance"
  instance_name    = "mynet-id"
  instance_zone    = "asia-southeast2-a"
  instance_network = google_compute_network.my_network.id
}