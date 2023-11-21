# IAM role for EC2 instances
resource "aws_iam_role" "ec2_cloudwatch_logs_role" {
  name = "ec2-cloudwatch-logs-role"
  assume_role_policy = jsonencode(
  {
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = "sts:AssumeRole",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "ec2-cloudwatch-logs-role"
  }
}

# IAM policy to allow EC2 instances to put logs to CloudWatch
resource "aws_iam_policy" "ec2_cloudwatch_logs_policy" {
  name        = "ec2-cloudwatch-logs-policy"
  description = "Allow EC2 instances to put logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Effect = "Allow",
        Resource = "*"
      },
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.ec2_cloudwatch_logs_role.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_logs_policy.arn
}

# Instance profile for EC2 instances to use the role
resource "aws_iam_instance_profile" "ec2_cloudwatch_logs_profile" {
  name = "ec2-cloudwatch-logs-profile"
  role = aws_iam_role.ec2_cloudwatch_logs_role.name
}
