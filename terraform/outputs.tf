# --- Database Outputs ---
output "rds_hostname" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.rds.address
}

output "rds_port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.rds.port
}

# --- SQS Outputs ---
output "sqs_queue_url" {
  description = "The URL of the SQS queue for sending transactions"
  value       = aws_sqs_queue.msg_queue.url
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.msg_queue.arn
}

# --- Lambda & Logging Outputs ---
output "lambda_function_name" {
  description = "The name of the processor function"
  value       = aws_lambda_function.processor.function_name
}

output "cloudwatch_log_group" {
  description = "Where to look for your transaction logs"
  value       = aws_cloudwatch_log_group.lambda_log.name
}

# --- Secret Info ---
output "secret_arn" {
  description = "The ARN of the secret storing your DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}