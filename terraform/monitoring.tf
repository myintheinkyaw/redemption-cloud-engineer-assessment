# Monitoring and Observability Configuration for Redemption Platform

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Name        = "${var.project_name}-alerts"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Random ID for Unique Resources
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# AWS Managed Prometheus Workspace
resource "aws_prometheus_workspace" "main" {
  alias = "${var.project_name}-prometheus"

  tags = {
    Name        = "${var.project_name}-prometheus"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# AWS Managed Grafana Workspace
resource "aws_grafana_workspace" "main" {
  name                     = "${var.project_name}-grafana"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana.arn

  tags = {
    Name        = "${var.project_name}-grafana"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM Role for Grafana
resource "aws_iam_role" "grafana" {
  name = "${var.project_name}-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "grafana.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-grafana-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM Policy for Grafana
resource "aws_iam_policy" "grafana" {
  name        = "${var.project_name}-grafana-policy"
  description = "Policy for Grafana to access monitoring resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms",
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "xray:GetTraceSummaries",
          "xray:BatchGetTraces"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-grafana-policy"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "grafana" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana.arn
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EKS", "CPUUtilization", "ClusterName", var.eks_cluster_name]
          ]

          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", "${var.project_name}-aurora-cluster"],
            [".", "DatabaseConnections", ".", "."]
          ]

          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Aurora Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ElastiCache",
              "CPUUtilization",
              "ReplicationGroupId",
              aws_elasticache_replication_group.main.id
            ]
          ]

          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Redis Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              split("/", aws_lb.main.arn)[1]
            ]
          ]

          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Metrics"
        }
      }
    ]
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.project_name}/application"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-application-logs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/${var.project_name}/api"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-api-logs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/${var.project_name}/audit"
  retention_in_days = 90

  tags = {
    Name        = "${var.project_name}-audit-logs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ALB High Error Alarm
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "HTTPCode_Target_5XX_Count"
  namespace   = "AWS/ApplicationELB"

  period    = 300
  statistic = "Sum"
  threshold = 10

  alarm_description = "High error rate detected on ALB"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    LoadBalancer = split("/", aws_lb.main.arn)[1]
  }
}

# ALB High Latency Alarm
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "${var.project_name}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "TargetResponseTime"
  namespace   = "AWS/ApplicationELB"

  period    = 300
  statistic = "Average"
  threshold = 1

  alarm_description = "High latency detected on ALB"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  dimensions = {
    LoadBalancer = split("/", aws_lb.main.arn)[1]
  }
}

# X-Ray
resource "aws_xray_group" "main" {
  group_name        = var.project_name
  filter_expression = "service(\"${var.project_name}\")"

  tags = {
    Name        = "${var.project_name}-xray-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

/*
CloudWatch Synthetics Canary intentionally disabled
for assessment repository because required zip package
does not exist in source control.

resource "aws_synthetics_canary" "api_health" {}
*/