
# ==========================================================
# DSO303 Assignment 2 - GitHub Actions OIDC
# ==========================================================

# ----------------------------------------------------------
# 1. GitHub Actions OIDC Identity Provider
# ----------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name    = "DSO303-GitHub-OIDC"
    Project = "DSO303-Assignment2"
  }
}

# ----------------------------------------------------------
# 2. GitHub Actions Deployment IAM Role
# ----------------------------------------------------------

resource "aws_iam_role" "github_deploy" {
  name = "DSO303-Assignment2-GitHub-Deploy-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:Namgay282004/DSO303-Assignment2:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "DSO303-GitHub-Deploy-Role"
    Project = "DSO303-Assignment2"
  }
}

# ----------------------------------------------------------
# 3. Amazon ECR Push Permissions
# ----------------------------------------------------------

resource "aws_iam_role_policy" "github_ecr_push" {
  name = "DSO303-GitHub-ECR-Push"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = aws_ecr_repository.backend.arn
      }
    ]
  })
}

# ----------------------------------------------------------
# 4. EC2 Auto Scaling Instance Refresh Permissions
# ----------------------------------------------------------

# Allow GitHub Actions to refresh backend EC2 instances
# after publishing a new Docker image to Amazon ECR.

resource "aws_iam_role_policy" "github_asg_refresh" {
  name = "DSO303-GitHub-ASG-Refresh"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeInstanceRefreshes"
        ]

        Resource = aws_autoscaling_group.api.arn
      }
    ]
  })
}

# ----------------------------------------------------------
# 5. Frontend S3 and CloudFront Deployment Permissions
# ----------------------------------------------------------

resource "aws_iam_role_policy" "github_frontend_deploy" {
  name = "DSO303-GitHub-Frontend-Deploy"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.frontend.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.frontend.arn}/*"
      },
      {
        Effect = "Allow"

        Action = [
          "cloudfront:CreateInvalidation"
        ]

        Resource = aws_cloudfront_distribution.frontend.arn
      }
    ]
  })
}

