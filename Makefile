REGION?=us-west-2
EXECUTABLES = bash aws terraform jq kubectl
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

install:
	bash scripts/bootstrap-aws.sh

init-%:
	bash scripts/terraform-env.sh $@ init

plan-%:
	bash scripts/terraform-env.sh $@ plan

apply-%:
	bash scripts/terraform-env.sh $@ apply

.PHONY: clean install init plan apply
