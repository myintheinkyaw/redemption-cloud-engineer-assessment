# Aurora PostgreSQL Configuration for Redemption Platform

resource "random_password" "aurora_master" {
  length  = 16
  special = false
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project_name}-aurora-cluster"

  engine         = "aurora-postgresql"
  engine_version = var.database_engine_version

  database_name   = var.database_name
  master_username = var.database_username
  master_password = random_password.aurora_master.result

  backup_retention_period      = var.backup_retention_days
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  storage_encrypted = true
  kms_key_id        = aws_kms_key.aurora.arn

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name

  engine_mode = "provisioned"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 8
  }

  iam_database_authentication_enabled = true

  deletion_protection = false

  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]

  tags = {
    Name        = "${var.project_name}-aurora-cluster"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_rds_cluster_instance" "main" {
  count = 2

  identifier         = "${var.project_name}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id

  instance_class = "db.serverless"

  engine         = aws_rds_cluster.main.engine
  engine_version = aws_rds_cluster.main.engine_version

  publicly_accessible = false

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.aurora_monitoring.arn

  tags = {
    Name        = "${var.project_name}-aurora-instance-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-aurora-subnet-group"

  subnet_ids = [
    aws_subnet.private_data_1a.id,
    aws_subnet.private_data_1b.id
  ]

  tags = {
    Name        = "${var.project_name}-aurora-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_key" "aurora" {
  description             = "KMS key for Aurora PostgreSQL encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-aurora-kms-key"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${var.project_name}-aurora-key"
  target_key_id = aws_kms_key.aurora.key_id
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${var.project_name}-aurora-parameter-group"
  family      = "aurora-postgresql15"
  description = "Custom parameter group for Redemption Platform Aurora PostgreSQL"

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name        = "${var.project_name}-aurora-parameter-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role" "aurora_monitoring" {
  name = "${var.project_name}-aurora-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-aurora-monitoring-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "aurora_monitoring" {
  role       = aws_iam_role.aurora_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_cloudwatch_metric_alarm" "aurora_cpu" {
  alarm_name          = "${var.project_name}-aurora-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/RDS"

  period    = 300
  statistic = "Average"
  threshold = 80

  alarm_description = "Aurora PostgreSQL CPU utilization is high"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.id
  }

  tags = {
    Name        = "${var.project_name}-aurora-cpu-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_storage" {
  alarm_name          = "${var.project_name}-aurora-free-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2

  metric_name = "FreeLocalStorage"
  namespace   = "AWS/RDS"

  period    = 300
  statistic = "Average"
  threshold = 10737418240

  alarm_description = "Aurora PostgreSQL free storage is low"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.id
  }

  tags = {
    Name        = "${var.project_name}-aurora-storage-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}