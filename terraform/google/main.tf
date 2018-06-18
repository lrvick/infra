terraform {
  required_version = "~> 0.11.7"
  backend "gcs" {
    project = "lrvick-terraform-admin"
    bucket = "lrvick-terraform-admin"
    prefix = "terraform"
  }
}

provider "google" {
  project = "lrvick-production"
}

#* google_project_services.lrvick: Error creating services: failed to list services: googleapi: Error 403: The caller does not have permission, forbidden
#resource "google_project_services" "lrvick" {
#  project = "lrvick-production"
#  services = [
#    "cloudbilling.googleapis.com",
#    "cloudresourcemanager.googleapis.com",
#    "compute.googleapis.com",
#    "container.googleapis.com",
#    "containerregistry.googleapis.com",
#    "iam.googleapis.com",
#  ]
#}
