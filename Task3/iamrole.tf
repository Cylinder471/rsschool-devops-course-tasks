resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role" "GithubActionsRole" {
  name = "GithubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::650251696415:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Cylinder471/rsschool-devops-course-tasks:*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_policy" "k3s_worker_ssm" {
  name = "${var.project_name}-k3s-worker-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:PutParameter",
          "ssm:DeleteParameter"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/edu/${var.project_name}/k3s/token",
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/edu/${var.project_name}/k3s/kubeconfig"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/${var.kms_key_id}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "k3s_worker_ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.k3s_worker_ssm.arn
}
resource "aws_iam_instance_profile" "k3s_worker_profile" {
  name = "${var.project_name}-k3s-worker-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "github_actions_ssm" {
  name        = "${var.project_name}-github-actions-ssm-policy"
  description = "Allow GitHub Actions workflow to manage SSM parameters for k3s"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:DeleteParameter"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/edu/${var.project_name}/k3s/token",
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/edu/${var.project_name}/k3s/kubeconfig"
        ]
      }
    ]
  })
}

# Привязка политики к GitHub OIDC роли
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.GithubActionsRole.name
  policy_arn = aws_iam_policy.github_actions_ssm.arn
}