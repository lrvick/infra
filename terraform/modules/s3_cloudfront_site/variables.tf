variable "domain" {
    description = "Domain name static site will be accessible by"
}

variable "cloudfront_price_class" {
    description = "Price Class for CloudFront"
    default = "PriceClass_200"
}

variable "logs_bucket" {
    description = "S3 bucket to store access logs in"
    default = ""
}

variable "assets_bucket" {
    description = "S3 bucket to store site assets in"
    default = ""
}
