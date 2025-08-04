resource "aws_iam_policy" "k3s_worker_ssm" {
  name = "${var.project_name}-k3s-worker-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/edu/${var.project_name}/k3s/token"
      }
    ]
  })
}