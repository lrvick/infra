terraform {
    backend "s3" {
        bucket = "lrvick-root-terraform"
        key    = "state/root.tfstate"
        region = "us-west-2"
        lock_table = "lrvick-root-terraform"
    }
}

provider "aws" {
 	region = "us-west-2"
}
