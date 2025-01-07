# Source account where cloudtrail resources are being deployed.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_management_profile
}

# Destination account of the S3 bucket where the cloudtrail logs will be stored.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_audit_profile
  alias   = "audit_account"
}