REGION?=us-west-2
EXECUTABLES = bash aws terraform jq kubectl
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

clean:
	aws cloudformation delete-stack --stack-name global

install:
	bash scripts/bootstrap-aws.sh

get:
	terraform get

init:
	terraform init

terraform: prepare

plan: get terraform

apply: get terraform

.PHONY: clean install init plan apply
