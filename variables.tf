variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  type        = string
  default     = "ami-0c101f26f147fa7fd"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}
