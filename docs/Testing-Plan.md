# Security Testing Plan - SafeShare v.2

## Phase 1: Static Analysis (Week 8 + Monday)
- [ ] Terraform code review (terraform fmt, validate)
- [ ] Secrets scanning: truffleHog + gitleaks on repo
- [ ] IAM policy analysis: Access Analyzer + Checkov / tfsec
- [ ] Dockerfile lint: Hadolint
- Deliverable: tfsec report, no hardcoded secrets

## Phase 2: Infrastructure Testing (Week 9 Day 1-2 - Tuesday)
- [ ] Prowler CIS Benchmark scan: `prowler aws --compliance cis_1.4`
- [ ] Security Hub compliance check: Review CIS failures
- [ ] AWS Config rules evaluation: s3-bucket-public-read-prohibited, rds-encrypted, etc.
- [ ] VPC Flow Logs verification + CloudTrail S3 Data Events verification
- Deliverable: Prowler HTML report saved to docs/security/prowler-report.html

## Phase 3: Application Testing (Week 9 Day 3-4 - Wednesday/Thursday)
- [ ] Docker image scanning: `trivy image safeshare-api:latest` + `trivy image safeshare-lambda-scan:latest`
- [ ] OWASP ZAP web application scan: `zap baseline -t https://ALB-DNS`
- [ ] Manual penetration testing:
  - Auth: Try login without MFA, expired JWT, IDOR /files/:id of other user
  - S3: Try to access S3 object directly without presigned URL (should 403)
  - Upload: Try uploading .exe with EICAR test virus string -> Lambda should quarantine
- [ ] Lambda testing: Invoke Lambda with fake EventBridge event (should fail validation)
- [ ] EventBridge testing: Check EventBridge Archive + Replay
- Deliverable: Trivy scan results, ZAP report, Manual test doc

## Phase 4: Event-Driven & Resilience Testing (v.2 Specific)
- [ ] Upload 10 images rapidly -> Check Lambda concurrency + Thumbnails created
- [ ] Upload EICAR test file -> Check quarantine bucket + SNS alert
- [ ] Check DLQ: Force Lambda error -> Message goes to SQS DLQ -> Alarm triggers
- [ ] Test presigned URL expiry (15 min) -> After 15 min should be 403
- [ ] Chaos: Stop 1 ECS task manually -> ALB health check should remove it, ASG should create new one

## Phase 5: Remediation (Week 9 Day 5 - Friday Morning)
- [ ] Fix critical and high findings from Prowler, Trivy, ZAP
- [ ] Document accepted risks (e.g., NAT GW cost vs PrivateLink)
- [ ] Re-test to verify fixes (Run Prowler again, ZAP again)
- [ ] Final evidence bundle: All reports in S3 evidence bucket

## Testing Deliverables
- Prowler HTML report
- Trivy scan results (JSON + table)
- OWASP ZAP HTML report
- Manual testing documentation (markdown with screenshots)
- Lambda logs + EventBridge event samples
- CloudWatch Dashboard screenshot

## Timeline
Mon: Phase 1 + 2 start
Tue: Phase 2 + Lambda build + Phase 3 start (Trivy)
Wed: Phase 3 + 4 (ZAP + Event flood)
Thu: Phase 4 + Slides prep + Backup screenshots
Fri: Phase 5 morning + Demo afternoon
