
# IAM role for API EC2 instances
resource "aws_iam_role" "api" {
  name = "DSO303-Assignment2-API-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "DSO303-Assignment2"
  }
}

# API permissions
resource "aws_iam_role_policy" "api" {
  name = "DSO303-API-Policy"
  role = aws_iam_role.api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.marking.arn
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = [
          "${aws_s3_bucket.assignments.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "api" {
  name = "DSO303-Assignment2-API-Profile"
  role = aws_iam_role.api.name
}

# IAM role for Marking Worker EC2 instances
resource "aws_iam_role" "worker" {
  name = "DSO303-Assignment2-Worker-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "DSO303-Assignment2"
  }
}

# Worker permissions
resource "aws_iam_role_policy" "worker" {
  name = "DSO303-Worker-Policy"
  role = aws_iam_role.worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.marking.arn
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = [
          "${aws_s3_bucket.assignments.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "worker" {
  name = "DSO303-Assignment2-Worker-Profile"
  role = aws_iam_role.worker.name
}
