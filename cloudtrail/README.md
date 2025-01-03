# AWS CloudTrail Setup Best Practices

## Enable Multi-Region CloudTrail

### Cost
- [ ] **First Trail Free:** The first CloudTrail is included in the free tier. Any additional trail tracking the same management events will incur costs.
- [ ] **Exclude High-Volume Events:** Exclude AWS KMS events and Amazon RDS Data API events to reduce high-volume events that generate higher costs.

### Delivery to S3 Bucket
- [ ] **Centralized Logging:** Deliver logs to a central S3 bucket in a separate AWS account and limit access.
  - [ ] Enable MFA for access to the S3 bucket.
  - [ ] Turn on versioning for the S3 bucket.
  - [ ] Turn on server-side encryption for CloudTrail log files (e.g., AES-256 or KMS encryption).
  - [ ] Enable log file validation.
- [ ] **Lifecycle Management:** Configure object lifecycle management to manage log storage costs efficiently.
- [ ] **Restrict Permissions:** Set up an S3 bucket policy to strictly control access:
  - Use IAM policies to allow only specific roles or users to access logs.
  - Enable logging for all access to the bucket.

### Access Management
- [ ] **Limit Full Access Permissions:** Restrict the `AWSCloudTrail_FullAccess` policy to administrators only. Users with this permission can disable or reconfigure auditing functions.
- [ ] **Least Privilege Principle:** Grant only the necessary permissions to users, roles, and services.

### Monitoring and Notifications
- [ ] **Enable CloudWatch Alarms:** Set up CloudWatch Alarms to monitor unexpected changes in CloudTrail logs or configuration.
- [ ] **SNS Notifications:** Configure SNS topics to send alerts for any suspicious activity detected in logs.

### Additional Security Measures
- [ ] **Organization Trails:** Use AWS Organizations to set up organization trails that automatically apply CloudTrail configurations across accounts.
- [ ] **Multi-Factor Authentication:** Enforce MFA for access to sensitive resources, including the S3 bucket storing logs.
- [ ] **Monitor Trail Integrity:** Periodically review the CloudTrail configuration for unauthorized changes.

---

### Notes
- Regularly review and update the CloudTrail setup to align with compliance requirements and AWS best practices.
- Test your configuration in a non-production environment before applying it to production.
