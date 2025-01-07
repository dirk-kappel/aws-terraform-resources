variable "aws_region" {
  description = "The region where the resources are being deployed."
  default     = "us-east-1"
}

variable "aws_management_profile" {
  description = "The account where the cloudtrail resources are being deployed."
  default     = "personal.management"
}

variable "aws_audit_profile" {
  description = "The account where the s3 bucket is being deployed that is storing the cloudtrail logs."
  default     = "personal.development"
}