variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "db_username" {
  type        = string
  default = "admin"
}

variable "db_password" {
  type        = string
  default = "Cloud123"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}
