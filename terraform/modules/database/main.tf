# --- Random Password ---
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# --- Subnet Group ---
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# --- Parameter Group ---
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-db-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = {
    Name = "${var.project_name}-db-pg"
  }
}

# --- RDS Instance ---
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro" # Free tier eligible
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "todo"
  username = "admin"
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  parameter_group_name   = aws_db_parameter_group.main.name

  skip_final_snapshot = true # For demo/dev only
  publicly_accessible = false
  multi_az            = false # Set to true for HA (costs more)

  tags = {
    Name = "${var.project_name}-db"
  }
}

# --- Alarms ---

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.project_name}-db-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when DB CPU > 80%"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "connections" {
  alarm_name          = "${var.project_name}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "Alarm when DB connections > 50"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "storage" {
  alarm_name          = "${var.project_name}-db-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "2000000000" # 2GB
  alarm_description   = "Alarm when Free Storage < 2GB"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }
}
