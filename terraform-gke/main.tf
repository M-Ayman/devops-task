variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

provider "google" {
  credentials = file("./atomic-kit-236110-c77fd540a3e1.json")
  project = var.project_id
  region  = var.region
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  node_locations = [
    "us-central1-a",
  ]

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  initial_node_count = "1"
  #node_count = var.gke_num_nodes

  autoscaling {
   # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
   min_node_count = "1"

   # Maximum number of nodes in the NodePool. Must be >= min_node_count.
   max_node_count = "3"
 }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
