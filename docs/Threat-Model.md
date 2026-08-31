# Capstone Threat Model (STRIDE) - SafeShare v.2

## Assets
- User credentials (email, bcrypt hash, TOTP secret)
- Customer PII (name, email, file metadata)
- Application secrets (DB password, JWT secret, S3 keys) - in Secrets Manager
- User Files (S3 Objects) - Confidential
- Infrastructure: ECS Tasks, Lambda Functions, EventBridge Bus, RDS, Redis

## Data Flow Diagram
Client -> CloudFront/WAF -> ALB -> ECS Fargate -> RDS/Redis
                |
Upload -> S3 -> EventBridge -> Lambda (Scan, Thumb, Audit)

## Threats & Mitigations

### S - Spoofing
**Threat 1:** Attacker steals session cookie / JWT
- Mitigation: HttpOnly, Secure, SameSite=Strict cookies, Short-lived JWT (15min), Refresh token rotation, MFA enforced
- Priority: High
- Backlog Item: Implement secure session management with MFA

**Threat 2:** Attacker invokes Lambda directly bypassing auth
- Mitigation: Lambda Resource Policy Deny public invoke, Only EventBridge can invoke, IAM least privilege
- Priority: High
- Backlog Item: Lock down Lambda invoke permissions

### T - Tampering
**Threat 1:** SQL injection modifies RDS data
- Mitigation: Parameterized queries (Sequelize / pg), WAF SQLi Rule, Input validation with Joi
- Priority: Critical
- Backlog Item: Implement input validation and parameterized queries

**Threat 2:** Attacker tampers S3 file to inject malware, bypassing scan
- Mitigation: S3 Object Lock, EventBridge triggers scan BEFORE file marked as AVAILABLE, Quarantine bucket
- Priority: Critical
- Backlog Item: Implement Lambda virus scan pipeline with quarantine

**Threat 3:** EventBridge event tampering (fake S3 event)
- Mitigation: EventBridge Event Pattern validation, Only allow events from our S3 ARN, Verify S3 object exists in Lambda
- Priority: Medium
- Backlog Item: Validate EventBridge events in Lambda

### R - Repudiation
**Threat:** User denies uploading malicious file
- Mitigation: CloudTrail S3 Data Events, S3 Access Logs, RDS Audit table (who uploaded what when), Lambda Audit Logs in CloudWatch
- Priority: Medium
- Backlog Item: Enable CloudTrail + application audit trail via Lambda-3

### I - Information Disclosure
**Threat 1:** S3 bucket exposes private files
- Mitigation: Block Public Access ON, No bucket policy allowing *, Presigned URLs only (15min), S3 encryption SSE-S3, CloudFront OAC
- Priority: Critical
- Backlog Item: Configure S3 security controls + presigned URL flow

**Threat 2:** Secrets leaked in Terraform state / logs
- Mitigation: Secrets Manager, Terraform remote state in S3 with encryption, No secrets in env vars plain, Scan with truffleHog
- Priority: Critical
- Backlog Item: Store all secrets in Secrets Manager

**Threat 3:** Lambda logs leak PII / file content
- Mitigation: Lambda log filtering, No console.log file content, CloudWatch Log Group encrypted with KMS
- Priority: High
- Backlog Item: Sanitize Lambda logging

### D - Denial of Service
**Threat 1:** DDoS on ALB
- Mitigation: AWS Shield Standard, CloudFront, WAF Rate Limiting Rule (100 req/5min per IP), ALB target group slow start
- Priority: Medium
- Backlog Item: Enable Shield and configure WAF rate limiting

**Threat 2:** Event flood - attacker uploads 10k files causing Lambda throttling + cost bomb
- Mitigation: S3 upload rate limiting in API, Lambda Reserved Concurrency (10), SQS DLQ between EventBridge and Lambda, Budget Alarm
- Priority: High
- Backlog Item: Implement Lambda concurrency + SQS buffer

### E - Elevation of Privilege
**Threat 1:** ECS Task Role has admin access
- Mitigation: Least privilege IAM: Task Role only rds:Connect, s3:PutObject/GetObject on specific bucket, secretsmanager:GetSecret, No iam:*
- Priority: High
- Backlog Item: Create least-privilege IAM roles for ECS and Lambda

**Threat 2:** User accesses other user's files via IDOR
- Mitigation: Row-level check: file.user_id == jwt.user_id, Presigned URL includes user check in DB
- Priority: Critical
- Backlog Item: Implement authorization middleware for file access
