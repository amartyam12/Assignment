resource "aws_iam_role" "ec2_cldwc_role" {
  name = "ec2-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ec2_cldwc_policy" {
  name = "ec2-cloudwatch-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cw_policy" {
  role = aws_iam_role.ec2_cldwc_role.name
  policy_arn = aws_iam_policy.ec2_cldwc_policy.arn
}
