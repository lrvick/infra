data "aws_route53_zone" "selected" {
    name = "${replace(var.domain, "/^.*\\.([^\\.]+)\\.([^\\.]+)$/", "$1.$2.")}"
}

resource "aws_route53_record" "record" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name = "${var.domain}"
    type = "A"
    alias {
        name = "${aws_cloudfront_distribution.s3.domain_name}"
        zone_id = "${aws_cloudfront_distribution.s3.hosted_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_s3_bucket" "assets" {
    bucket = "${var.assets_bucket}"
    acl = "private"
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.logs_bucket}"
    acl = "private"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "${var.domain}"
}

resource "aws_cloudfront_distribution" "s3" {
    origin {
        domain_name = "${aws_s3_bucket.assets.bucket_domain_name}"
        origin_id = "${var.domain}"
        s3_origin_config {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
        }
    }
    enabled = true
    is_ipv6_enabled = true
    comment = "Static website for ${var.domain}"
    default_root_object = "index.html"
    logging_config {
        include_cookies = false
        bucket = "${aws_s3_bucket.logs.bucket_domain_name}"
        prefix = "${var.domain}"
    }
    aliases = ["www.${var.domain}"]
    default_cache_behavior {
        allowed_methods = [
            "DELETE",
            "GET",
            "HEAD",
            "OPTIONS",
            "PATCH",
            "POST",
            "PUT"
        ]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "${var.domain}"
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }
    price_class = "PriceClass_200"
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
