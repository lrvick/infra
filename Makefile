REGION?=us-west-2

clean:
	aws cloudformation delete-stack --stack-name global

install:
	aws cloudformation deploy \
		--template-file cloudformation/global.yml \
		--stack-name global \
		--capabilities CAPABILITY_NAMED_IAM
	aws organizations create-account \
		--email lance@lrvick.net \
		--account-name "ci"
	aws organizations create-account \
		--email lance@lrvick.net \
		--account-name "production"
	aws organizations create-account \
		--email lance@lrvick.net \
		--account-name "staging"
	aws organizations create-account \
		--email lance@lrvick.net \
		--account-name "development"

get:
	terraform get

init:
	terraform init

terraform: prepare

plan: get terraform

apply: get terraform

.PHONY: install init plan apply
