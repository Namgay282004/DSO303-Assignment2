
# Peak Load and Availability Zone Resilience

## 1. Peak Load Handling

The system is designed to support 300–500 concurrent users during normal operations and up to 3,000 students starting an examination within five minutes.

Amazon CloudFront reduces frontend loading time, while the Application Load Balancer (ALB) distributes incoming requests across EC2 instances in two Availability Zones.

EC2 Auto Scaling adjusts computing capacity based on demand. Amazon RDS PostgreSQL stores examination answers, while Amazon SQS handles background tasks asynchronously to reduce API workload.

These are proposed capacity requirements. The system has not yet been load-tested with 3,000 concurrent students.

## 2. Availability Zone Resilience

The proposed architecture uses two Availability Zones (AZ-A and AZ-B) to improve availability and fault tolerance.

If one Availability Zone fails, the ALB can redirect requests to healthy EC2 instances in the remaining zone.

Amazon RDS Multi-AZ provides automatic database failover when the primary database becomes unavailable.

### 2.1 Availability Zone A Failover Simulation

![Availability Zone A Failover](../evidence/cloud-architecture-lab/az-a-failover.png)

**Figure 1:** Cloud Architecture Lab simulation showing successful HTTP 200 request handling during a simulated Availability Zone failure.

### 2.2 Availability Zone B Failover Simulation

![Availability Zone B Failover](../evidence/cloud-architecture-lab/az-b-failover.png)

**Figure 2:** Cloud Architecture Lab simulation showing automatic PostgreSQL database failover and successful HTTP 200 response delivery.

Cloud Architecture Lab simulations demonstrated successful request processing during the configured failover scenarios.

These results demonstrate simulated fault tolerance. Actual AWS failover behavior and recovery time have not yet been verified.

## 3. Recovery Objectives

The proposed architecture targets the following requirements:

| Requirement | Target |
|---|---|
| Availability | 99.9% during examinations |
| Recovery Point Objective (RPO) | Maximum 5 minutes of answer data loss |
| Recovery Time Objective (RTO) | Recovery within 1 hour |
| Data retention | 5 years |
| Security | Encryption in transit and at rest |

These are design targets rather than verified production results.

Actual recovery times, peak capacity, availability, and data-loss limits must be verified through AWS deployment and testing.

## 4. Conclusion

The proposed architecture improves scalability and reliability through load balancing, EC2 Auto Scaling, Multi-AZ database failover, and asynchronous processing.

Cloud Architecture Lab simulations demonstrated successful request handling during modeled failure scenarios.

Further production testing is required to confirm the proposed performance and recovery objectives.
