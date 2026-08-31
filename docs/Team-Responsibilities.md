# Team Responsibilities - Solo Plan - SafeShare v.2

This is a solo capstone project. All roles are handled by one engineer, but tasks are divided by days to follow Week 9 structure.

## Day 1 - Monday: Foundation & Deployment (Infrastructure & Networking Role)
- VPC and subnet configuration (Terraform modules/networking)
- Security groups and NACLs (least privilege)
- VPC Flow Logs + S3 Access Logs
- CloudTrail setup + S3 backend for Terraform state
- ALB + ECS Cluster creation
- End of Day: terraform apply works, base infra deployed

## Day 2 - Tuesday: Features & Integration (Application Security Role)
- Authentication and authorization (MFA, JWT)
- Input validation (Joi) + Parameterized queries
- Secrets management (Secrets Manager integration)
- WAF configuration + S3 security (Block Public Access, Presigned URLs)
- EventBridge Bus + S3 Event -> EventBridge wiring
- Lambda Functions development (Scan, Thumb, Audit)
- Docker build + ECR push + ECS deployment

## Day 3 - Wednesday: Optimization & Documentation (Data Protection & Compliance Role)
- Enable S3 default encryption + RDS encryption verification
- S3 Intelligent-Tiering + Fargate Spot for cost optimization
- Tagging pass: Project=SafeShare-v2, Env=prod, Owner
- Compliance matrix + Security Hub enablement
- Documentation: ARCHITECTURE.md with v.2 diagram, SECURITY.md, COSTS.md
- Cost analysis: Monthly projection with Lambda savings

## Day 4 - Thursday: Storytelling & Presentation Prep (Monitoring & Testing Role)
- GuardDuty and Security Hub findings review
- CloudWatch Dashboard + Alarms (3+ alarms)
- Security testing: Prowler, Trivy, tfsec, OWASP ZAP
- Incident response documentation
- Presentation slides + Demo script (upload -> EventBridge -> Lambda logs)
- Backup screenshots for demo fail-safe

## Day 5 - Friday: Demo Day & Retrospective
- 10-min presentation + Live Demo: Upload file -> Show EventBridge event -> Lambda logs -> Thumbnail appears
- Q&A preparation: Why ECS Fargate + Lambda? Why EventBridge over direct S3->Lambda?
- terraform destroy after demo to save credit
- RETROSPECTIVE.md + Archive project

## Tools Ownership (Solo)
- IaC: Terraform + GitHub Actions
- App: Node.js + Docker
- Event-Driven: Lambda + EventBridge + S3 Events
- Security: WAF, GuardDuty, Security Hub, Prowler, Trivy, ZAP
- Monitoring: CloudWatch + SNS

All responsibilities documented in commit history.
