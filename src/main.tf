resource "aws_iam_policy" "s3_list" {
  name        = "s3-list-policy"
  description = "Allow listing of S3 buckets"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : "arn:aws:s3:::*"
      }
    ]
  })
  tags = {
    Name = "s3-list-policy"
  }
}

variable "iam_users" {
  type = list(string)
  default = ["user1", "user2"]
}

locals {
  created_users = flatten([for x in aws_iam_user.iam_users[*]: [for k, v in x: k ]])
}

resource "aws_iam_user" "iam_users" {
  for_each = toset(var.iam_users)
  name = each.value
}

resource "aws_iam_policy_attachment" "user_policy" {
  name = "user-policy-attachment"
  users = local.created_users
  policy_arn = aws_iam_policy.s3_list.arn
}