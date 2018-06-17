data "aws_route53_zone" "selected" {
    name = "${replace(var.domain, "/^.*\\.([^\\.]+)\\.([^\\.]+)$/", "$1.$2.")}"
}

data "aws_acm_certificate" "primary" {
    provider = "aws.use1"
    domain   = "${var.domain}"
    statuses = ["ISSUED"]
}

resource "aws_route53_record" "assets" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name = "${var.domain}"
    type = "A"
    alias {
        name = "${aws_cloudfront_distribution.assets.domain_name}"
        zone_id = "${aws_cloudfront_distribution.assets.hosted_zone_id}"
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "redirect" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name = "www.${var.domain}"
    type = "A"
    alias {
        name = "${aws_cloudfront_distribution.redirect.domain_name}"
        zone_id = "${aws_cloudfront_distribution.redirect.hosted_zone_id}"
        evaluate_target_health = false
    }
}

data "aws_iam_policy_document" "assets" {
    statement {
        sid = "PublicReadAccess",
        principals {
            type = "AWS",
            identifiers = ["*"]
        },
        effect = "Allow",
        actions = ["s3:GetObject"],
        resources = ["${aws_s3_bucket.assets.arn}/*"],
        condition {
            test = "StringEquals",
            variable = "aws:UserAgent",
            values = ["CloudFront"]
        }
    }
}

data "aws_iam_policy_document" "redirect" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.redirect.arn}/*"]
        principals {
            type = "AWS"
            identifiers = ["*"]
        }
    }
}

resource "aws_s3_bucket_policy" "assets" {
    bucket = "${var.domain}"
    policy = "${data.aws_iam_policy_document.assets.json}"
}

resource "aws_s3_bucket_policy" "redirect" {
    bucket = "www.${var.domain}"
    policy = "${data.aws_iam_policy_document.redirect.json}"
}

resource "aws_s3_bucket" "assets" {
    bucket = "${var.domain}"
    acl = "public-read"
    website {
        index_document = "index.html"
        error_document = "404.html"
    }
    logging {
        target_bucket = "${aws_s3_bucket.logs.bucket}"
        target_prefix = "s3"
    }
}

resource "aws_s3_bucket" "redirect" {
    bucket = "www.${var.domain}"
    acl = "public-read"
    website {
        redirect_all_requests_to = "https://${var.domain}"
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.domain}-logs"
    acl = "log-delivery-write"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "${var.domain}"
}

resource "aws_cloudfront_distribution" "assets" {
    origin {
        domain_name = "${aws_s3_bucket.assets.website_endpoint}"
        origin_id = "${var.domain}"
        custom_origin_config {
            origin_protocol_policy = "http-only"
            http_port = "80"
            https_port = "443"
            origin_ssl_protocols = ["TLSv1"]
        }
        custom_header {
            name = "User-Agent"
            value = "CloudFront"
        }
    }
    enabled = true
    is_ipv6_enabled = true
    http_version = "http2"
    comment = "Static website for ${var.domain}"
    default_root_object = "index.html"
    logging_config {
        include_cookies = false
        bucket = "${aws_s3_bucket.logs.bucket_domain_name}"
        prefix = "cloudfront"
    }
    aliases = ["${var.domain}"]
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods = ["GET", "HEAD", "OPTIONS"]
        compress = true
        target_origin_id = "${var.domain}"
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
        viewer_protocol_policy = "redirect-to-https"
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
    custom_error_response {
       error_code         = 404
       response_code      = 200
       response_page_path = "/404.html"
    }
    viewer_certificate {
        acm_certificate_arn = "${data.aws_acm_certificate.primary.arn}"
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1"
    }
}

resource "aws_cloudfront_distribution" "redirect" {
    origin {
        origin_id = "origin-bucket-${aws_s3_bucket.redirect.id}"
        domain_name = "${aws_s3_bucket.redirect.website_endpoint}"
        custom_origin_config {
          origin_protocol_policy = "http-only"
          http_port = "80"
          https_port = "443"
          origin_ssl_protocols = ["TLSv1"]
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
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        compress = true
        target_origin_id = "origin-bucket-${aws_s3_bucket.redirect.id}"
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
        viewer_protocol_policy = "redirect-to-https"
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
        acm_certificate_arn = "${data.aws_acm_certificate.primary.arn}"
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1"
    }
}
