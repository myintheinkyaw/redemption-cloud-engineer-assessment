# Backup and Disaster Recovery Configuration for Redemption Platform

# AWS Backup Vault
resource "aws_backup_vault" "main" {
  name        = "redemption-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn

  tags = {
    Name        = "redemption-backup-vault"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# KMS Key for Backup Encryption
resource "aws_kms_key" "backup" {
  description             = "KMS key for AWS Backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "redemption-backup-kms-key"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "backup" {
  name          = "alias/redemption-backup-key"
  target_key_id = aws_kms_key.backup.key_id
}

# AWS Backup Plan
resource "aws_backup_plan" "main" {
  name = "redemption-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 2 * * ? *)" # Daily at 2 AM

    lifecycle {
      delete_after = 30 # Days
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.secondary.arn
      lifecycle {
        delete_after = 90 # Days
      }
    }
  }

  rule {
    rule_name         = "weekly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 ? * SUN *)" # Weekly on Sunday at 3 AM

    lifecycle {
      delete_after = 90 # Days
    }
  }

  rule {
    rule_name         = "monthly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 4 1 * ? *)" # Monthly on 1st at 4 AM

    lifecycle {
      delete_after = 365 # Days
    }
  }

  tags = {
    Name        = "redemption-backup-plan"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Secondary Backup Vault (for cross-region replication)
resource "aws_backup_vault" "secondary" {
  provider = aws.secondary

  name        = "redemption-backup-vault-secondary"
  kms_key_arn = aws_kms_key.backup_secondary.arn

  tags = {
    Name        = "redemption-backup-vault-secondary"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# KMS Key for Secondary Backup Vault
resource "aws_kms_key" "backup_secondary" {
  provider = aws.secondary

  description             = "KMS key for secondary AWS Backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "redemption-backup-kms-key-secondary"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "backup_secondary" {
  provider = aws.secondary

  name          = "alias/redemption-backup-key-secondary"
  target_key_id = aws_kms_key.backup_secondary.key_id
}

# Backup Selection
resource "aws_backup_selection" "main" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "redemption-backup-selection"
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }

  resources = [
  aws_rds_cluster.main.arn,
  aws_efs_file_system.main.arn
  ]
}

# IAM Role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "redemption-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "redemption-backup-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

# EFS File System for Persistent Storage
resource "aws_efs_file_system" "main" {
  creation_token = "redemption-efs"
  encrypted      = true
  kms_key_id     = aws_kms_key.efs.arn

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "redemption-efs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Backup      = "true"
  }
}

resource "aws_efs_mount_target" "main" {
  count = length([aws_subnet.private_app_1a.id, aws_subnet.private_app_1b.id])

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1b.id][count.index]
  security_groups = [aws_security_group.efs.id]
}

# KMS Key for EFS Encryption
resource "aws_kms_key" "efs" {
  description             = "KMS key for EFS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "redemption-efs-kms-key"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "efs" {
  name          = "alias/redemption-efs-key"
  target_key_id = aws_kms_key.efs.key_id
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name        = "redemption-efs-sg"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "NFS from EKS nodes"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "redemption-efs-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Velero Configuration for Kubernetes Backup
resource "aws_s3_bucket" "velero" {
  bucket = "redemption-velero-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "redemption-velero-bucket"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "velero" {
  bucket = aws_s3_bucket.velero.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for Velero
resource "aws_iam_role" "velero" {
  name = "redemption-velero-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:velero:velero-server"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "redemption-velero-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "velero" {
  name        = "redemption-velero-policy"
  description = "Policy for Velero to access S3 and EBS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.velero.arn}/*"
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.velero.arn
      }
    ]
  })

  tags = {
    Name        = "redemption-velero-policy"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "velero" {
  policy_arn = aws_iam_policy.velero.arn
  role       = aws_iam_role.velero.name
}

# EKS OIDC Provider for Velero
resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" # Thumbprint for EKS OIDC
  ]

  tags = {
    Name        = "redemption-eks-oidc-provider"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Outputs
output "backup_vault_arn" {
  description = "Primary backup vault ARN"
  value       = aws_backup_vault.main.arn
}

output "backup_vault_secondary_arn" {
  description = "Secondary backup vault ARN"
  value       = aws_backup_vault.secondary.arn
}

output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.main.id
}

output "velero_bucket_name" {
  description = "Velero S3 bucket name"
  value       = aws_s3_bucket.velero.bucket
}

output "velero_role_arn" {
  description = "Velero IAM role ARN"
  value       = aws_iam_role.velero.arn
}