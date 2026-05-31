# Output values for Redemption Platform infrastructure

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

output "private_app_subnet_ids" {
  description = "IDs of private app subnets"
  value       = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1b.id]
}

output "private_data_subnet_ids" {
  description = "IDs of private data subnets"
  value       = [aws_subnet.private_data_1a.id, aws_subnet.private_data_1b.id]
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID"
  value       = aws_security_group.eks_nodes.id
}

# Aurora PostgreSQL Outputs
output "aurora_cluster_endpoint" {
  description = "Aurora PostgreSQL cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
  sensitive   = true
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora PostgreSQL cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
  sensitive   = true
}

output "aurora_cluster_database_name" {
  description = "Aurora PostgreSQL database name"
  value       = aws_rds_cluster.main.database_name
}

output "aurora_master_password" {
  description = "Aurora PostgreSQL master password"
  value       = random_password.aurora_master.result
  sensitive   = true
}

# Redis Outputs
output "redis_endpoint" {
  description = "Redis endpoint"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
  sensitive   = true
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.main.port
}

output "redis_auth_token" {
  description = "Redis auth token"
  value       = random_password.redis_auth.result
  sensitive   = true
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

# Monitoring Outputs
output "prometheus_workspace_endpoint" {
  description = "Prometheus workspace endpoint"
  value       = aws_prometheus_workspace.main.prometheus_endpoint
  sensitive   = true
}

output "grafana_workspace_endpoint" {
  description = "Grafana workspace endpoint"
  value       = aws_grafana_workspace.main.endpoint
  sensitive   = true
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# Backup Outputs
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

# Security Group Outputs
output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    alb          = aws_security_group.alb.id
    eks_cluster  = aws_security_group.eks_cluster.id
    eks_nodes    = aws_security_group.eks_nodes.id
    aurora       = aws_security_group.aurora.id
    redis        = aws_security_group.redis.id
    efs          = aws_security_group.efs.id
    vpc_endpoints = aws_security_group.vpc_endpoints.id
    bastion      = aws_security_group.bastion.id
  }
}

# KMS Key Outputs
output "kms_key_arns" {
  description = "Map of KMS key ARNs"
  value = {
    aurora  = aws_kms_key.aurora.arn
    backup  = aws_kms_key.backup.arn
    efs     = aws_kms_key.efs.arn
  }
}

# IAM Role Outputs
output "iam_role_arns" {
  description = "Map of IAM role ARNs"
  value = {
    eks_cluster = aws_iam_role.eks_cluster.arn
    eks_nodes   = aws_iam_role.eks_nodes.arn
    backup      = aws_iam_role.backup.arn
    velero      = aws_iam_role.velero.arn
    grafana     = aws_iam_role.grafana.arn
  }
}

# S3 Bucket Outputs
output "s3_bucket_names" {
  description = "Map of S3 bucket names"
  value = {
    cloudfront_logs = aws_s3_bucket.cloudfront_logs.bucket
    synthetics      = aws_s3_bucket.synthetics.bucket
    velero          = aws_s3_bucket.velero.bucket
  }
}

# VPC Endpoint Outputs
output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value = {
    s3               = aws_vpc_endpoint.s3.id
    ecr_api          = aws_vpc_endpoint.ecr_api.id
    ecr_dkr          = aws_vpc_endpoint.ecr_dkr.id
    cloudwatch_logs  = aws_vpc_endpoint.cloudwatch_logs.id
    cloudwatch_metrics = aws_vpc_endpoint.cloudwatch_metrics.id
    sts              = aws_vpc_endpoint.sts.id
    eks              = aws_vpc_endpoint.eks.id
    elb              = aws_vpc_endpoint.elb.id
  }
}

# Kubeconfig Output
output "kubeconfig" {
  description = "Kubectl config for the EKS cluster"
  value = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name     = aws_eks_cluster.main.name
    cluster_endpoint = aws_eks_cluster.main.endpoint
    cluster_ca       = aws_eks_cluster.main.certificate_authority[0].data
  })
  sensitive = true
}