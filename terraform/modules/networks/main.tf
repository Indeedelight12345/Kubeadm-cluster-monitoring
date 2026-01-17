resource "google_compute_network" "this" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "VPC for kubeadm Kubernetes cluster"
}

resource "google_compute_subnetwork" "this" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}

resource "google_compute_firewall" "k8s" {
  name    = "k8s-firewall"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports = [
      "22",
      "6443",
      "2379-2380",
      "10250",
      "10251",
      "10252",
      "10255",
      "30000-32767"
    ]
  }

  allow {
    protocol = "udp"
    ports    = ["8472"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s"]
}
