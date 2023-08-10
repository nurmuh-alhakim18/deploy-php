resource "google_compute_firewall" "my_firewall" {
  name = "${var.firewall_name}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.firewall_ports}"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web-server"]
}