output "logs_bucket" {
    value = "${aws_s3_bucket.logs.bucket}"
}

output "assets_bucket" {
    value = "${aws_s3_bucket.assets.bucket}"
}
