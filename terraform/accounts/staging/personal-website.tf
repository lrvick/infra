module "personal-website" {
    source = "../../modules/s3_cloudfront_site"
    domain = "lrvick-stg.net"
}

data "aws_iam_policy_document" "personal_website_lambda_role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"],
        principals {
            type = "Service",
            identifiers = ["lambda.amazonaws.com"]
        },
    }
}

data "aws_iam_policy_document" "personal_website_lambda" {
    statement {
        effect = "Allow",
        actions = ["s3:ListBucket"],
        resources = ["arn:aws:s3:::${module.personal-website.assets_bucket}"],
    }
    statement {
        effect = "Allow",
        actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        resources = ["arn:aws:s3:::${module.personal-website.assets_bucket}/*"],
    }
}

resource "aws_iam_role" "personal_website_lambda" {
    assume_role_policy = "${data.aws_iam_policy_document.personal_website_lambda_role.json}"
}

resource "aws_iam_role_policy" "personal_website_lambda" {
    role = "${aws_iam_role.personal_website_lambda.id}"
    policy = "${data.aws_iam_policy_document.personal_website_lambda.json}"
}

data "archive_file" "personal_website_lambda" {
    type = "zip"
    source_dir = "../../files/lambda/rant_github_s3_uploader"
    output_path = "../../../.cache/lambda/rant_github_s3_uploader.zip"
}

resource "aws_lambda_function" "personal_website" {
    function_name = "rant_github_s3_uploader"
    filename = "../../../.cache/lambda/rant_github_s3_uploader.zip"
    source_code_hash = "${data.archive_file.personal_website_lambda.output_base64sha256}"
    role = "${aws_iam_role.personal_website_lambda.arn}"
    description = "Rant Github S3 Uploader for Personal Website"
    handler = "index.handler"
    runtime = "python3.6"
    environment {
        variables = {
            GIT_BRANCH = "staging",
            S3_BUCKET = "${module.personal-website.assets_bucket}",
            TRUSTED_KEYS = "E90A401336C8AAA9"
        }
    }
}

resource "aws_sns_topic" "personal_website_lambda" {
    name = "personal_website_lambda"
}

resource "aws_sns_topic_subscription" "personal_website_lambda" {
    topic_arn = "${aws_sns_topic.personal_website_lambda.arn}"
    protocol = "lambda"
    endpoint = "${aws_lambda_function.personal_website.arn}"
}

resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.personal_website.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.personal_website_lambda.arn}"
}
