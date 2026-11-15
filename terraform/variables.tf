
variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ RDS deployment"
  type        = bool
  default     = false
}
