# Permissions

# CloudTrail
resource "aws_cloudtrail" "organization_trail" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_policy]

  name           = "Organization_Multi_Region_Trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_bucket.id
  #   cloud_watch_logs_group_arn    = 
  #   cloud_watch_logs_role_arn     = 
  enable_log_file_validation    = true
  enable_logging                = false # Set to false for testing purposes only.
  is_multi_region_trail         = true
  is_organization_trail         = true
  s3_key_prefix                 = "org-trail"
  include_global_service_events = true
}

