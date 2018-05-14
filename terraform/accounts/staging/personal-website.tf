module "personal-website" {
    source = "../../modules/s3_cloudfront_site"
    domain = "lrvick-stg.net"
}

## Create Lambda function with ability to deploy to cloudfronted s3 bucket

data "aws_iam_policy_document" "personal_website_lambda_role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"],
        principals {
            type = "Service",
            identifiers = [
                "lambda.amazonaws.com",
                "apigateway.amazonaws.com"
            ]
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

resource "random_string" "personal_website_webhook_secret" {
  length = 20
  special = true
  override_special = "/@\" "
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
            GIT_REPO = "git@gith"
            GIT_BRANCH = "staging",
            S3_BUCKET = "${module.personal-website.assets_bucket}",
            TRUSTED_KEYS = "E90A401336C8AAA9"
            WEBHOOK_SECRET = "${random_string.personal_website_webhook_secret.result}"
        }
    }
}

# Create AWS API Gateway endpoint that can trigger lambda function

resource "aws_api_gateway_rest_api" "personal_website" {
    name = "personal_website"
    description = "Gateway to trigger static site deployment from git"
}

resource "aws_api_gateway_resource" "personal_website" {
    rest_api_id = "${aws_api_gateway_rest_api.personal_website.id}"
    parent_id = "${aws_api_gateway_rest_api.personal_website.root_resource_id}"
    path_part = "hook"
}

resource "aws_api_gateway_method" "personal_website" {
    rest_api_id = "${aws_api_gateway_rest_api.personal_website.id}"
    resource_id = "${aws_api_gateway_resource.personal_website.id}"
    http_method = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "personal_website" {
    rest_api_id = "${aws_api_gateway_rest_api.personal_website.id}"
    resource_id = "${aws_api_gateway_resource.personal_website.id}"
    http_method = "${aws_api_gateway_method.personal_website.http_method}"
    type = "AWS_PROXY"
    uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.personal_website.function_name}/invocations"
    integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "personal_website" {
  depends_on = [
    "aws_api_gateway_method.personal_website",
    "aws_api_gateway_integration.personal_website",
  ]
  rest_api_id = "${aws_api_gateway_rest_api.personal_website.id}"
  stage_name = "prod"
}

resource "aws_lambda_permission" "personal_website" {
    function_name = "${aws_lambda_function.personal_website.arn}"
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.personal_website.id}/*/${aws_api_gateway_method.personal_website.http_method}${aws_api_gateway_resource.personal_website.path}"
}

## Return values needed to provide to deployment notifier

output "personal_website_deploy_webhook_url" {
    value = "https://${aws_api_gateway_deployment.personal_website.rest_api_id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.personal_website.stage_name}${aws_api_gateway_resource.personal_website.path}"
}

output "personal_website_deploy_webhook_secret" {
    value = "${random_string.personal_website_webhook_secret.result}"
}
