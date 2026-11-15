output "db_endpoint" {
  description = "The connection endpoint of the MySQL database"
  value       = aws_db_instance.mysql.endpoint
}

output "db_address" {
  description = "The hostname of the MySQL database"
  value       = aws_db_instance.mysql.address
}

output "db_port" {
  description = "The port of the MySQL database"
  value       = aws_db_instance.mysql.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.mysql.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.mysql.username
}

output "db_password" {
  description = "The master password for the database"
  value       = random_password.db_password.result
  sensitive   = true
}

output "redis_endpoint" {
  description = "The primary endpoint address of the Redis cluster"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "The port of the Redis cluster"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_auth_token" {
  description = "The auth token for Redis transit encryption"
  value       = random_password.redis_auth_token.result
  sensitive   = true
}

output "db_security_group_id" {
  description = "Security group ID for RDS MySQL"
  value       = aws_security_group.db.id
}

output "redis_security_group_id" {
  description = "Security group ID for Redis"
  value       = aws_security_group.redis.id
}
