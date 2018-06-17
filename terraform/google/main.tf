terraform {
  required_version = "~> 0.11.7"
}

data "external" "terraform-admin-credentials" {
  program = ["bash", "${path.module}/scripts/terraform_decrypt_file.sh"]
  query = {
    file = "secrets/terraform-admin.json.asc"
  }
}

data "terraform_remote_state" "lrvick" {
  backend = "gcs"
  config {
    project = "lrvick-terraform-admin"
    bucket = "lrvick-terraform-admin"
    prefix = "terraform"
    credentials = "${data.external.terraform-admin-credentials.result.file}"
  }
}

provider "google" {
  project = "lrvick-production"
  credentials = "${data.external.terraform-admin-credentials.result.file}"
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
