resource "google_container_cluster" "primary" {
  name = "lrvick-production"
  zone = "us-west1-a"
  min_master_version = "1.10.4-gke.0"
  node_version = "1.10.4-gke.0"
  initial_node_count = 3
  additional_zones = [ "us-west1-b", "us-west1-c" ]
  node_config {
    machine_type = "n1-standard-1"
    image_type = "COS"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/source.read_only",
    ]
  }
}

locals {
  k8s_name = "${google_container_cluster.primary.name}"
  k8s_host = "https://${google_container_cluster.primary.endpoint}"
  k8s_username = "${google_container_cluster.primary.master_auth.0.username}"
  k8s_password = "${google_container_cluster.primary.master_auth.0.password}"
  k8s_client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  k8s_client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  k8s_cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

provider "kubernetes" {
  host = "${local.k8s_host}"
  username = "${local.k8s_username}"
  password = "${local.k8s_password}"
  client_certificate = "${local.k8s_client_certificate}"
  client_key = "${local.k8s_client_key}"
  cluster_ca_certificate = "${local.k8s_cluster_ca_certificate}"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
}

data "template_file" "kubeconfig" {
  template = "${file("templates/kubeconfig.tpl")}"
  vars {
    cluster_name = "${local.k8s_name}"
    certificate_authority_data = "${base64encode(local.k8s_cluster_ca_certificate)}"
    server = "${local.k8s_host}"
    username = "${local.k8s_username}"
    password = "${local.k8s_password}"
  }
}

output "kubeconfig" {
  value = "${data.template_file.kubeconfig.rendered}"
}


# From here we get into RBAC bootstrapping which does not -yet- have any native
# support in terraform. See PR:
# https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73

data "external" "google-cloud-sdk" {
  program = ["bash", "${path.module}/scripts/terraform_google_cloud_sdk.sh"]
}

locals {
  cloud_sdk_path="${data.external.google-cloud-sdk.result.path}/bin"
  k8s_temp_dir = "${path.cwd}/.tmp/k8s"
  k8s_rbac_config = <<EOF
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: concourse
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: default
    namespace: default
EOF
}

resource "null_resource" "kubernetes_rbac_apply" {
  triggers {
    configuration = "${local.k8s_rbac_config}",
    cluster = "${local.k8s_host}"
  }
  provisioner "local-exec" {
    command = "mkdir -p ${local.k8s_temp_dir}"
  }
  provisioner "local-exec" {
    command = "echo \"${data.template_file.kubeconfig.rendered}\" > ${local.k8s_temp_dir}/kubeconfig"
  }
  provisioner "local-exec" {
    command = "${local.cloud_sdk_path}/kubectl apply --server=${local.k8s_host} --kubeconfig=${local.k8s_temp_dir}/kubeconfig -f - <<EOF\n${local.k8s_rbac_config}\nEOF"
  }
  provisioner "local-exec" {
    command = "${local.cloud_sdk_path}/kubectl delete --server=${local.k8s_host} --kubeconfig=${local.k8s_temp_dir}/kubeconfig -f - <<EOF\n${local.k8s_rbac_config}\nEOF"
    when = "destroy"
  }
}
