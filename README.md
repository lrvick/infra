# lrvick's Infra

This repo is there I manage all of the live configuration for my personal
infrastructure.

While this is intended only for personal use, I attempt to provide abstractions
so any of these patterns or modules can be re-used as desired for others with
similar needs.

Mostly I am documenting this for my future self, because that guy forgets
everything and needs every little detail laid out for him.

## Setup

Create DynamoDB table and versioned S3 bucket to store Terraform state:

```
export TF_PREFIX="lrvick-production"
aws s3api create-bucket \
  --bucket "$TF_PREFIX-terraform" \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-bucket-versioning \
  --bucket "$TF_PREFIX-terraform" \
  --versioning-configuration Status=Enabled
aws dynamodb create-table \
  --table-name "$TF_PREFIX-terraform" \
  --attribute-definitions "AttributeName=LockID,AttributeType=S" \
  --key-schema "AttributeName=LockID,KeyType=HASH" \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

Now you can fill in all remaining config and deploy infra with:

```
terraform apply
```
