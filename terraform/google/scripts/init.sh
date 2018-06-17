#!/bin/bash -e
set -e

dir=$(dirname "$0")
google_cloud_sdk=$(bash "${dir}/google-cloud-sdk.sh")
PATH="$PATH:${google_cloud_sdk}/bin"

organization_id="208307739756" # gcloud organizations list
billing_account_id="00615F-8E944E-A742EC" # gcloud beta billing accounts list
tf_admin="lrvick-terraform-admin"
tf_project="lrvick-production"
tf_creds="$HOME/.config/gcloud/terraform-admin.json"

if ! gcloud projects list \
	--format json \
	| jq -er ".[] | select(.name==\"$tf_admin\") | .name" > /dev/null ; then

	gcloud projects create ${tf_admin} \
		--organization ${organization_id} \
		--set-as-default

	gcloud beta billing projects link ${tf_admin} \
		--billing-account ${billing_account_id}

	gcloud iam service-accounts create terraform \
		--display-name "Terraform admin account"

	gcloud iam service-accounts keys create "${tf_creds}" \
		--iam-account terraform@${tf_admin}.iam.gserviceaccount.com

	gsutil mb -p ${tf_admin} "gs://${tf_admin}"
	gsutil versioning set on "gs://${tf_admin}"
fi

gcloud config set project "${tf_project}"

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com

gcloud projects add-iam-policy-binding ${tf_admin} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/viewer

gcloud projects add-iam-policy-binding ${tf_admin} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/storage.admin

gcloud organizations add-iam-policy-binding ${organization_id} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${organization_id} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/iam.serviceAccountActor

gcloud organizations add-iam-policy-binding ${organization_id} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/compute.admin

gcloud organizations add-iam-policy-binding ${organization_id} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/billing.user

gcloud organizations add-iam-policy-binding ${organization_id} \
	--member serviceAccount:terraform@${tf_admin}.iam.gserviceaccount.com \
	--role roles/container.admin
