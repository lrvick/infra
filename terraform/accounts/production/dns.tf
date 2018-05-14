resource "aws_route53_zone" "personal" {
    name = "lrvick.net"
}

resource "aws_route53_record" "wildcard" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "*.lrvick.net"
    type = "A"
    ttl  = "300"
    records = ["104.207.150.22"]
}

resource "aws_route53_record" "keybase" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "lrvick.net"
    type = "TXT"
    ttl = "300"
    records = ["keybase-site-verification=LyzhpqOMwzciC47VCWjWGszpCDzzvDw4fG7OK0P3zws"]
}

resource "aws_route53_record" "mx" {
    zone_id = "${aws_route53_zone.personal.zone_id}"
    name = "${aws_route53_zone.personal.name}"
    type = "MX"
    ttl = "300"
    records = [
        "1 aspmx.l.google.com",
        "5 alt1.aspmx.l.google.com",
        "5 alt2.aspmx.l.google.com",
        "10 alt3.aspmx.l.google.com",
        "10 alt4.aspmx.l.google.com"
    ]
}
