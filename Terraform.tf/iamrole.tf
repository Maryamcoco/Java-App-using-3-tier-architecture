# The IAM Role (The "Identity")
resource "aws_iam_role" "app_role" {
  name = "JavaApp-EC2-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#The Instance Profile (The "Pass" for EC2)
resource "aws_iam_instance_profile" "app_profile" {
  name = "JavaApp-Instance-Profile"
  role = aws_iam_role.app_role.name
}

#The Custom Policy
resource "aws_iam_policy" "s3_access_policy" {
  name        = "JavaAppS3AccessPolicy"
  description = "Allows EC2 to get and put objects in the project bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        # Ensure this bucket name matches your actual S3 bucket
        Resource = "arn:aws:s3:::my-terraform-state-javaapp/*"
      }
    ]
  })
}

#The Attachment (Tying it all together)
resource "aws_iam_role_policy_attachment" "custom_s3_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Attach the standard CloudWatch Agent Policy to your existing role
resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}