terraform {
  backend "s3" {
    bucket = "ey-wk7-terraformstatebucket"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}