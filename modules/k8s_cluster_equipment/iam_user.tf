resource "aws_iam_user" "k8s" {
  name = var.k8s_iam_user_name
}

resource "aws_iam_policy_attachment" "k8s_csi_driver" {
  name       = "k8s-aws-ebs-csi-driver-policy"
  users = [aws_iam_user.k8s.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_user_policy" "k8s_ecr" {
  name = "K8S-ECR-FullAccess-Policy"
  user = aws_iam_user.k8s.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy" "k8s_ecr_public" {
  name = "K8S-ECR-Public-FullAccess-Policy"
  user = aws_iam_user.k8s.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ecr-public:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy" "k8s_secrets" {
  name = "K8SSecrets"
  user = aws_iam_user.k8s.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:CancelRotateSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:StopReplicationToReplica",
          "secretsmanager:ReplicateSecretToRegions",
          "secretsmanager:RestoreSecret",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:RemoveRegionsFromReplication"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:::secret:/k8s*"
      },
      {
        Action = [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets",
          "secretsmanager:BatchGetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy" "k8s_s3" {
  name = "K8SS3"
  user = aws_iam_user.k8s.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:Dissociate*",
          "s3:Initiate*",
          "s3:Describe*",
          "s3:Abort*",
          "s3:Associate*",
          "s3:Update*",
          "s3:List*",
          "s3:Delete*",
          "s3:Create*",
          "s3:Put*",
          "s3:Get*"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::k8s*"
      },
      {
        Action = [
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:ListAccessPoints",
          "s3:CreateStorageLensGroup",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:ListStorageLensGroups",
          "s3:ListStorageLensConfigurations",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessGrantsInstances",
          "s3:CreateJob"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}