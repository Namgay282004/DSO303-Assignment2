# Peak Load and Availability Zone Resilience

## 1. Peak Load Handling

The system is designed to support 300–500 concurrent users during normal operations and up to 3,000 students starting an exam within five minutes.

Amazon CloudFront reduces frontend loading time, while the Application Load Balancer (ALB) distributes incoming requests across EC2 instances in two Availability Zones. EC2 Auto Scaling adjusts computing capacity based on demand. Amazon RDS PostgreSQL stores exam answers, while Amazon SQS handles background tasks asynchronously to reduce API workload.

## 2. Availability Zone Resilience

The architecture uses two Availability Zones (AZ-A and AZ-B) to improve availability and fault tolerance.

If one Availability Zone fails, the ALB can redirect requests to healthy EC2 instances in the remaining zone. Amazon RDS Multi-AZ provides automatic database failover when the primary database becomes unavailable.

Cloud Architecture Lab simulations demonstrated successful request processing during both AZ-A and AZ-B outage scenarios, returning HTTP 200 responses.

## 3. Recovery Objectives

The architecture targets:

- **Availability:** 99.9% during exams.
- **RPO:** Maximum 5 minutes of answer data loss.
- **RTO:** Recovery within 1 hour.
- **Data retention:** 5 years.
- **Security:** Encryption in transit and at rest.

These are design targets. Actual recovery times, peak capacity, and data-loss limits must be verified through AWS deployment and testing.

## 4. Conclusion

The proposed architecture improves scalability and reliability through load balancing, Auto Scaling, Multi-AZ database failover, and asynchronous processing. The Lab simulations demonstrate basic fault tolerance, while production testing is required to confirm all performance and recovery targets.