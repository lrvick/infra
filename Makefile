REGION?=us-west-2

get:
	terraform get

init:
	terraform init

terraform: prepare

plan: get terraform

apply: get terraform

.PHONY: init plan apply
