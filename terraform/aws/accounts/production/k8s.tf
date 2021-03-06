resource "google_container_cluster" "primary" {
  name = "marcellus-wallace"
  zone = "us-west1-a"
  initial_node_count = 3
  additional_zones = [
    "us-west1-b",
    "us-west1-c",
  ]
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
