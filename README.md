# ce-capstone-final-safeshare
Author; Faramarz Karamizadeh  Sep.2026

# SafeShare - Multi-AZ Fault Tolerant System

Student: Farama - Chemnitz University

## 1. Architecture
- 3 AZs: eu-central-1a,b,c
- Public subnets: ALB
- Private subnets: ASG (3-6 instances t3.micro)
- S3 with lifecycle 7 days + EventBridge
- 5 Lambdas for metrics and audit
- DynamoDB for tokens (on-demand)

## 2. How to Deploy
terraform init
terraform apply -var="cert_arn=arn:..." -var="sns_email=..."

## 3. Resilience
- AZ failure: ALB routes to other 2 AZs
- Instance failure: ASG replaces in 60s
- RTO: 2 min, RPO: 0

## 4. FinOps
- Budget: 50 USD monthly, alert 80%
- Anomaly detection: 20 USD threshold
- Right-sizing: t3.micro instead of t3.medium saves 50%
- S3 lifecycle deletes after 7 days
- NAT Gateway: 1 instead of 3 to save cost

## 5. Monitoring
6 CloudWatch Alarms:
1. ALB 5xx
2. ALB Latency
3. ASG CPU
4. RAM via CW Agent
5. Low Upload (business)
6. Large File (business)

Dashboard: SafeShare-Dashboard

## 6. Security
- HTTPS with ACM
- Private subnets for app
- IAM least privilege
- S3 encrypted
