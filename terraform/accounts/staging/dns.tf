resource "aws_route53_zone" "personal" {
    name = "lrvick-stg.net"
    tags {
        Environment = "staging"
    }
}
