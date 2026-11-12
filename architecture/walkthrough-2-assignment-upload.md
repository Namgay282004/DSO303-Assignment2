### Walkthrough 2: Assignment Submission and Asynchronous Processing

The second walkthrough was simulated using Cloud Architecture Lab.

The student initiated a POST request to `/api/submissions/confirm`. The request passed through Amazon CloudFront and the Application Load Balancer, which selected a healthy EC2 API instance in Availability Zone A.

The API accessed Amazon SQS through the simulated private subnet routing and NAT Gateway. IAM authorization was successful, allowing the API to perform the `sqs:SendMessage` operation.

Amazon SQS accepted the message, and Marking Worker AZ-A successfully received, processed, and deleted it. The student received an HTTP 202 response.

All 11 simulation steps completed successfully, with a simulated response time of 89 milliseconds at a configured load of 10 requests per second.

This simulation verifies the submission-confirmation and asynchronous processing path. The actual 40 MB S3 upload, file-size validation, database persistence, and tutor email delivery require separate verification during implementation.