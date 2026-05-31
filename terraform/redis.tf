# ElastiCache Redis Configuration for Redemption Platform

# Redis Replication Group (Multi-AZ High Availability)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.project_name}-redis"
  replication_group_description = "Redis replication group for ${var.project_name}"

  node_type      = var.redis_node_type
  engine         = "redis"
  engine_version = var.redis_engine_version

  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name

  security_group_ids = [
    aws_security_group.redis.id
  ]

  port = 6379

  automatic_failover_enabled = true
  multi_az_enabled           = true

  num_cache_clusters = 2

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  auth_token = random_password.redis_auth.result

  maintenance_window       = "sun:05:00-sun:06:00"
  snapshot_window          = "04:00-05:00"
  snapshot_retention_limit = var.backup_retention_days

  tags = {
    Name        = "${var.project_name}-redis"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Redis Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project_name}-redis-parameter-group"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = {
    Name        = "${var.project_name}-redis-parameter-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Redis Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name = "${var.project_name}-redis-subnet-group"

  subnet_ids = [
    aws_subnet.private_data_1a.id,
    aws_subnet.private_data_1b.id
  ]

  tags = {
    Name        = "${var.project_name}-redis-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Random Password for Redis Authentication
resource "random_password" "redis_auth" {
  length  = 16
  special = false
}

# CloudWatch Alarm - Redis CPU
resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.project_name}-redis-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/ElastiCache"

  period    = 300
  statistic = "Average"
  threshold = 80

  alarm_description = "Redis CPU utilization is high"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.main.id
  }

  tags = {
    Name        = "${var.project_name}-redis-cpu-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch Alarm - Redis Memory
resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.project_name}-redis-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "DatabaseMemoryUsagePercentage"
  namespace   = "AWS/ElastiCache"

  period    = 300
  statistic = "Average"
  threshold = 80

  alarm_description = "Redis memory utilization is high"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.main.id
  }

  tags = {
    Name        = "${var.project_name}-redis-memory-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch Alarm - Redis Connections
resource "aws_cloudwatch_metric_alarm" "redis_connections" {
  alarm_name          = "${var.project_name}-redis-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CurrConnections"
  namespace   = "AWS/ElastiCache"

  period    = 300
  statistic = "Average"
  threshold = 1000

  alarm_description = "Redis connections are high"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.main.id
  }

  tags = {
    Name        = "${var.project_name}-redis-connections-alarm"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}