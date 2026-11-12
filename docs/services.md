# AWS Service Documentation

**Course:** DSO303 – Cloud Computing  
**Assignment:** Assignment 2 – Architecture Design and Deployment  
**Project:** University Online Examination and Assignment Submission Platform

## 1. Introduction

This document describes the AWS services selected for the university's online examination and assignment submission platform.

The platform supports approximately 8,000 students and 400 staff. It handles 300–500 concurrent users normally and targets a peak of 3,000 students starting an examination within five minutes.

The architecture uses two Availability Zones to improve reliability, scalability, security, and fault tolerance.

## 2. AWS Service Selection and Justification

### 2.1 Networking and Content Delivery

| AWS Service | Role | Why over an alternative | Connects to |
|---|---|---|---|
| Amazon VPC | Provides an isolated network for application resources. | More network control than placing all services on public networks. | EC2, RDS, ALB, NAT Gateway |
| Public Subnets | Host internet-facing resources across two AZs. | Separate public access from internal workloads for better security. | ALB, NAT Gateway |
| Private Application Subnets | Host API servers and marking workers. | More secure than public EC2 instances because direct inbound internet access is restricted. | EC2, ALB, NAT Gateway |
| Isolated Database Subnets | Host the primary and standby databases. | Prevent direct internet access, unlike deploying a database in public subnets. | RDS PostgreSQL, EC2 |
| Amazon Route 53 | Provides DNS resolution for the application. | Managed DNS with integration into AWS services, compared with manually maintained DNS infrastructure. | CloudFront |
| Amazon CloudFront | Delivers frontend files and forwards API requests. | Reduces latency and origin traffic compared with serving all frontend assets directly from EC2. | Route 53, S3, ALB, WAF |
| Application Load Balancer | Distributes HTTPS requests across API instances in two AZs. | Supports HTTP routing and health checks, unlike a basic TCP-only load-balancing approach. | CloudFront, EC2 |
| NAT Gateway | Provides outbound internet access for private EC2 instances. | Avoids managing NAT instances and provides a managed outbound networking service. | Private subnets, EC2 |

### 2.2 Compute and Scaling

| AWS Service | Role | Why over an alternative | Connects to |
|---|---|---|---|
| Amazon EC2 – API | Runs the backend application for examinations, autosaving, submissions, and user operations. | Provides server configuration control compared with Lambda's execution model. | ALB, RDS, S3, SQS, Cognito |
| Amazon EC2 – Marking Worker | Processes background marking and notification jobs. | Allows continuous queue polling and longer-running processing compared with synchronous API execution. | SQS, RDS, SES |
| EC2 Auto Scaling | Adjusts API and worker capacity according to workload. | More efficient than permanently provisioning enough instances for peak examination traffic. | EC2, ALB, CloudWatch |

### 2.3 Database and Storage

| AWS Service | Role | Why over an alternative | Connects to |
|---|---|---|---|
| Amazon RDS PostgreSQL | Stores users, examinations, answers, submissions, marks, and results. | Managed backups and database maintenance reduce operational work compared with self-hosted PostgreSQL on EC2. | API EC2, Marking Worker |
| RDS Multi-AZ | Maintains a synchronously replicated standby for database failover. | Better availability than a single-AZ database deployment. | RDS Primary, RDS Standby |
| Amazon S3 – Frontend | Stores static frontend assets. | More durable and operationally simpler for static files than hosting them on an EC2 web server. | CloudFront |
| Amazon S3 – Assignments | Stores PDF and ZIP assignment submissions up to 50 MB. | More suitable for object storage than EBS; presigned URLs allow direct browser uploads. | API EC2, Student Browser, IAM |

### 2.4 Security and Identity

| AWS Service | Role | Why over an alternative | Connects to |
|---|---|---|---|
| Amazon Cognito | Authenticates students, tutors, and administrators. | Provides managed user authentication instead of implementing a custom identity system. | Frontend, API |
| AWS WAF | Protects the application against common web attacks. | Provides managed filtering rules instead of relying only on application-level checks. | CloudFront |
| AWS Certificate Manager | Manages TLS certificates for HTTPS. | Reduces manual certificate renewal and management. | CloudFront, ALB |
| AWS IAM | Controls permissions between AWS services. | Role-based temporary credentials are safer than hardcoded access keys. | EC2, S3, SQS, SES |
| AWS Secrets Manager | Stores database credentials and application secrets. | Supports managed secret storage and rotation instead of plaintext configuration files. | EC2, RDS |

### 2.5 Asynchronous Processing and Monitoring

| AWS Service | Role | Why over an alternative | Connects to |
|---|---|---|---|
| Amazon SQS | Queues marking and notification jobs. | More reliable during traffic spikes than processing every background task synchronously. | API EC2, Marking Worker |
| Amazon SES | Sends tutor notifications and released examination results by email. | Managed email delivery avoids operating a custom SMTP server. | Marking Worker |
| Amazon CloudWatch | Collects application metrics, logs, and alarms. | Centralized monitoring is easier to manage than manually collecting logs from each server. | EC2, ALB, RDS, Auto Scaling |

### 2.6 CI/CD Services

| Service | Role | Why over an alternative | Connects to |
|---|---|---|---|
| AWS CodeCommit | Stores application source code in the Lab architecture. | Integrates with AWS developer services instead of requiring a separately managed Git server. | CodePipeline |
| AWS CodePipeline | Coordinates build, testing, and deployment stages. | Automates releases instead of requiring manual deployment steps. | CodeBuild, CodeDeploy |
| AWS CodeBuild | Builds and tests application code. | Managed build environments avoid maintaining dedicated build servers. | CodePipeline |
| AWS CodeDeploy | Deploys application updates to EC2 instances. | Supports controlled deployments and rollback mechanisms compared with manual SSH deployment. | EC2, CodePipeline |

**Implementation note:** The Lab diagram shows AWS CodeCommit and CodePipeline. For the actual GitHub repository, GitHub Actions may be used to trigger AWS deployment automatically on pushes to `main`. The final documentation must match whichever CI/CD implementation is actually deployed.

## 3. Important Service Configurations

| Component | Planned configuration |
|---|---|
| VPC | `10.0.0.0/16` |
| Public Subnet A | `10.0.1.0/24` |
| Public Subnet B | `10.0.2.0/24` |
| Private App Subnet A | `10.0.3.0/24` |
| Private App Subnet B | `10.0.4.0/24` |
| Isolated DB Subnet A | `10.0.5.0/24` |
| Isolated DB Subnet B | `10.0.6.0/24` |
| ALB | HTTPS listener, health checks, targets in both AZs |
| EC2 | Private subnet placement, IAM roles, Auto Scaling |
| RDS | PostgreSQL, Multi-AZ standby, encryption, automated backups |
| S3 | Private buckets, encryption, versioning where appropriate, five-year retention lifecycle |
| SQS | Durable queue, worker polling, retry handling and dead-letter queue |
| CloudWatch | API errors, latency, EC2 utilization, RDS health and queue-depth alarms |
| IAM | Least-privilege permissions for API and marking workers |
| Secrets Manager | Database credentials stored securely |
| CI/CD | Automated build, test, deployment and rollback strategy |

These are the intended production configurations. Settings not demonstrated in Cloud Architecture Lab must be verified during actual AWS deployment.

## 4. Security and Data Protection

The architecture uses multiple security controls:

- **Encryption in transit:** HTTPS/TLS protects communication between clients and public application endpoints. Database connections should also use TLS.
- **Encryption at rest:** RDS and S3 use encryption for stored data.
- **Network isolation:** API and worker instances run in private subnets, while databases run in isolated subnets.
- **Access control:** Cognito manages authentication, while application authorization enforces student, tutor, and administrator permissions.
- **IAM permissions:** API and worker instances receive only the permissions required for their operations.
- **Data retention:** S3 lifecycle and retention policies are configured to preserve required records for five years.
- **Secrets management:** Database passwords and other sensitive credentials are stored in Secrets Manager.

## 5. Scalability and Availability

The architecture distributes API servers and marking workers across two Availability Zones.

During examination peaks, EC2 Auto Scaling can increase compute capacity, while CloudFront reduces static-content traffic reaching the backend.

Amazon SQS separates background marking and notification tasks from interactive examination requests.

RDS Multi-AZ provides database failover if the primary database becomes unavailable.

The architecture targets 99.9% availability, an RPO of five minutes, and an RTO of one hour. These objectives require validation through load, recovery, and data-integrity testing.

## 6. Cloud Architecture Lab Verification

The following simulation results have been observed:

| Test | Observed result |
|---|---|
| GET current examination | HTTP 200 |
| POST examination answers | HTTP 200 |
| Asynchronous submission processing | HTTP 202; queue processing demonstrated |
| AZ-A outage | HTTP 200 after failover |
| AZ-B outage | HTTP 200 after failover |

The simulations demonstrate the modeled request paths and failure behavior. They do not replace actual AWS deployment tests.

## 7. Conclusion

The selected AWS services provide a foundation for a scalable, secure, and highly available university examination platform.

The design combines managed networking, distributed compute, Multi-AZ database availability, object storage, asynchronous processing, monitoring, and automated deployment.

The final AWS implementation will be used to verify the production configurations, upload functionality, notification delivery, scalability, and recovery objectives.