### Walkthrough 1: Student Opens an Exam and Autosaves Answers

The first walkthrough was simulated using Cloud Architecture Lab.

Initially, the student sent a GET request to `/api/exams/current`. The request passed through Amazon CloudFront and the Application Load Balancer, which selected a healthy EC2 API instance in Availability Zone A. The API forwarded a SQL request to Amazon RDS PostgreSQL, and the simulated transaction completed successfully. The student received an HTTP 200 response.

Next, a POST request was sent to `/api/exams/current/answers` to represent the autosave operation. This request followed the same architecture path and successfully completed all nine simulation steps, returning HTTP 200 in 134 milliseconds.

Both request simulations completed successfully at a configured load of 10 requests per second. The simulation validates the request path but does not independently verify the automatic 30-second interval or persistence of actual answer data. These will be tested during application deployment.