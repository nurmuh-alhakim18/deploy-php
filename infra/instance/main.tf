resource "google_compute_instance" "vm_instance" {
  name = "${var.instance_name}"
  zone = "${var.instance_zone}"
  machine_type = "${var.instance_type}"

  tags = ["web-server"]

  network_interface {
    network = "${var.instance_network}"
    
    access_config {
      nat_ip = google_compute_address.my_static_ip.address
    }
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
}

resource "google_compute_disk" "vm_disk" {
  name = "${var.instance_name}"
  size = "30"
  zone = "asia-southeast2-a"
}

resource "google_compute_address" "my_static_ip" {
  name   = "my-static-ip-address"
  region = "asia-southeast2"
}