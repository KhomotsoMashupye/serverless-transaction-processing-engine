variable "aws_region" {
  type    = string
  default = "af-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "transactions-vpc"
}

variable "availability_zones" {
  type    = list(string)
  default = ["af-south-1a", "af-south-1b"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "sqs_queue_name" {
  type    = string
  default = "transactions-queue"
}

variable "lambda_function_name" {
  type    = string
  default = "transaction-processor"
}

variable "lambda_role_name" {
  type    = string
  default = "lambda-processor-role"
}

variable "lambda_handler" {
  type    = string
  default = "index.handler"
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs22.x"
}

variable "lambda_zip_file" {
  type    = string
  default = "lambda_function.zip"
}

variable "tags" {
  type    = map(string)
  default = { Project = "Financial-Engine", Environment = "Production" }
}

# RDS Variables
variable "rds_identifier" {
  type    = string
  default = "rds-tx-db"
}

variable "rds_engine" {
  type    = string
  default = "postgres"
}

variable "rds_engine_version" {
  type    = string
  default = "16.12"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_db_name" {
  type    = string
  default = "transactions"
}

variable "rds_username" {
  type    = string
  default = "dbadmin"
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "db_sg_name" {
  type    = string
  default = "rds-security-group"
}

variable "db_subnet_group_name" {
  type    = string
  default = "rds-subnet-group"
}

variable "db_secret_name" {
  type    = string
  default = "prod/db/password"
}