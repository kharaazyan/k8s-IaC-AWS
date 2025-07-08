variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "pub_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "all_inet_subnet" {
  type    = string
  default = "0.0.0.0/0"
}

variable "public_ip" {
  type    = bool
  default = true
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ami_id" {
  type    = string
  default = "ami-02003f9f0fde924ea"
  description = "Ubuntu 22.04 LTS AMI for eu-central-1"
}

variable "key_pair_name" {
  type    = string
  default = "secret-key"
  description = "Name of the AWS key pair to use for SSH access"
}

variable "volume_size" {
  type    = number
  default = 10
  description = "Size of the root volume in GB"
}

variable "volume_type" {
  type    = string
  default = "gp3"
  description = "Type of the root volume"
}

# Security Group Variables
variable "allowed_ssh_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of IP addresses allowed to SSH to instances (use specific IPs in production)"
}

variable "allowed_api_ips" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of IP addresses allowed to access Kubernetes API (use specific IPs in production)"
}

variable "environment" {
  type        = string
  default     = "development"
  description = "Environment name (development, staging, production)"
}