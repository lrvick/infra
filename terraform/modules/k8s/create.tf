resource "aws_route53_zone" "k8s" {
    name = "${var.region}.k8s.${var.base_domain}"
}

resource "aws_s3_bucket" "k8s" {
    bucket = "${var.region}.k8s.${var.base_domain}"
    acl = "private"
}

resource "null_resource" "kops_supported_version" {
    provisioner "local-exec" {
        command = "kops version | grep ${var.kops_version}"
    }
}

resource "null_resource" "create_cluster" {
    depends_on = [
        "aws_s3_bucket.k8s",
        "aws_route53_zone.k8s",
        "null_resource.kops_supported_version"
    ]
    provisioner "local-exec" {
        command = "\
            kops create cluster \
                --target=terraform \
                --dns=${var.dns} \
                --topology=${var.topology}
                --dns-zone ${aws_route53_zone.k8s.id}
                --zones=${join(",", var.slave_zones)} \
                --master-zones=${join(",", var.master_zones)} \
                --networking=${var.networking} \
                --node-count=${var.node_asg_desired} \
                --api-loadbalancer-type=${api_loadbalancer_type} \
                --vpc=${var.vpc_id} \
                --state=s3://${aws_s3_bucket.k8s.id} \
                --kubernetes-version ${var.k8s_version} \
                --out=/tmp/terraform-config
                 ${var.region}.k8s.${var.base_domain} \
        "
    }
    provisioner "local-exec" {
        when = "destroy"
        command = " \
            kops delete cluster \
                --yes \
                --state=s3://${aws_s3_bucket.k8s.id} \
                --unregister ${var.region}.k8s.${var.base_domain} \
        "
    }
}
