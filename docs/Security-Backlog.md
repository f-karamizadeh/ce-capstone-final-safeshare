# Security Backlog - SafeShare v.2

## Epic 1: Authentication & Authorization (7 tasks)
- [ ] Implement user registration with email verification (Cognito or custom + SES)
- [ ] Implement login with bcrypt password hashing (cost 12)
- [ ] Add MFA using TOTP (speakeasy lib) - Google Authenticator compatible
- [ ] Create IAM roles with least privilege: ECS Task Role, Lambda Exec Role, ALB Logs Role
- [ ] Implement JWT-based sessions (15min access, 7d refresh, rotation)
- [ ] Implement authorization middleware to prevent IDOR on /files/:id
- [ ] Add account lockout after 5 failed login attempts (Redis counter)

## Epic 2: Data Protection (7 tasks)
- [ ] Enable S3 default encryption SSE-S3 + Bucket Key
- [ ] Enable RDS encryption at rest + Enable deletion protection
- [ ] Configure HTTPS-only ALB listener (HTTP 80 -> 443 redirect) + ACM cert
- [ ] Store all secrets in Secrets Manager (DB, JWT, Redis auth)
- [ ] Implement S3 Block Public Access ON + Policy Deny HTTP
- [ ] Implement presigned URL flow (15min expiry) instead of public S3
- [ ] Enable S3 versioning + Object Lock for ransomware protection

## Epic 3: Network Security (6 tasks)
- [ ] Deploy VPC (10.0.0.0/16) with 2 public / 2 private subnets across 2 AZs
- [ ] Configure security groups least privilege: ALB (443 from 0.0.0.0/0), ECS (from ALB only), RDS (from ECS only, 5432), Redis (from ECS only)
- [ ] Deploy RDS + ElastiCache in private subnets (no public IP)
- [ ] Enable VPC Flow Logs to CloudWatch
- [ ] Configure Network ACLs: Allow 443, 80, Ephemeral ports, Deny rest
- [ ] Enable WAF on ALB + CloudFront with AWS Managed Rules (SQLi, XSS, Rate limit)

## Epic 4: Event-Driven Security Automation - v.2 NEW (5 tasks)
- [ ] Create EventBridge Custom Bus SafeShareBus with encryption
- [ ] Configure S3 Event Notification -> EventBridge (ObjectCreated:*)
- [ ] Build Lambda-1 FileScan: ClamAV / virus scanning + move to quarantine bucket if infected
- [ ] Build Lambda-2 Thumbnailer: Sharp lib to create thumbnail, save to thumb/ prefix
- [ ] Build Lambda-3 AuditLogger: Write event to RDS audit_logs + CloudWatch Metric

## Epic 5: Monitoring & Incident Response (6 tasks)
- [ ] Enable CloudTrail in all regions with S3 Data Events + CloudWatch Logs
- [ ] Enable GuardDuty + Security Hub (CIS Benchmark)
- [ ] Configure CloudWatch Alarms: Unauthorized API calls, Root usage, Lambda errors >5, ALB 5xx >10, S3 Bucket becomes public
- [ ] Create incident response runbook (RUNBOOK.md) for malware detection
- [ ] Set up SNS alerts for critical findings (email + Slack)
- [ ] Enable SQS DLQ for failed Lambda invocations + Alarm on DLQ messages

## Epic 6: Compliance & Auditing (3 tasks)
- [ ] Enable Security Hub with CIS AWS Foundations Benchmark v1.4
- [ ] Create compliance matrix mapping controls to CIS
- [ ] Automate evidence collection (Prowler + Security Hub export to S3)

## Epic 7: Security Testing (7 tasks) - Total 41 tasks
- [ ] Run Prowler security assessment (CIS) - Generate HTML report
- [ ] Scan Docker images with Trivy (App + Lambda images)
- [ ] Scan Terraform with tfsec / Checkov
- [ ] Conduct OWASP ZAP scan on ALB endpoint
- [ ] Perform secrets scanning with truffleHog / gitleaks
- [ ] Manual test: IDOR, JWT tampering, S3 presigned URL expiry
- [ ] Document findings and remediations in SECURITY.md

Total: 41 Tasks (Requirement was 20+)
