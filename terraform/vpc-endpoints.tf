# VPC Endpoints for Redemption Platform
# Required endpoints for EKS, S3, ECR, and other AWS services

# S3 Gateway Endpoint (no cost)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_app_1a.id,
    aws_route_table.private_app_1b.id,
    aws_route_table.private_data_1a.id,
    aws_route_table.private_data_1b.id
  ]

  tags = {
    Name        = "redemption-s3-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ECR API Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-ecr-api-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ECR DKR Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-ecr-dkr-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch Logs Interface Endpoint
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-cloudwatch-logs-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch Metrics Interface Endpoint
resource "aws_vpc_endpoint" "cloudwatch_metrics" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.monitoring"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-cloudwatch-metrics-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# STS Interface Endpoint
resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.sts"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-sts-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# EKS Interface Endpoint
resource "aws_vpc_endpoint" "eks" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.eks"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-eks-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Elastic Load Balancing Interface Endpoint
resource "aws_vpc_endpoint" "elb" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "redemption-elb-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Secret Manager Interface Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]
  tags = {
    Name        = "redemption-secretsmanager-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# KMS Interface Endpoint
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.kms"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name        = "redemption-kms-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "redemption-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.private_app_1a.cidr_block,
      aws_subnet.private_app_1b.cidr_block,
      aws_subnet.private_data_1a.cidr_block,
      aws_subnet.private_data_1b.cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "redemption-vpc-endpoints-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}