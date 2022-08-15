variable "name" {
  default = "project"
}

variable "environment" {
  default = "prod"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "project_cluster"
}

variable "region" {
  description = "The region to deploy the cluster"
  type        = string
  default     = "us-east-1"
}

variable "instance_size" {
  description = "The size of the cluster nodes"
  type        = string
  default     = "t3.small"
}

variable "node_count" {
  description = "The number of nodes"
  type        = string
  default     = "6"
}

variable "node_min" {
  description = "The number of minimum count of nodes in AutoScalling Group"
  type        = string
  default     = "1"
}

variable "node_desired" {
  description = "The number of desired count of nodes in AutoScalling Group"
  type        = string
  default     = "6"
}

variable "app_min_capacity" {
  description = "Minimum number of ECS task replicas to run"
  type        = string
  default     = "1"
}

variable "app_des_capacity" {
  description = "Desired number of ECS task replicas to run"
  type        = string
  default     = "6"
}

variable "app_max_capacity" {
  description = "Maximum number of ECS task replicas to run"
  type        = string
  default     = "6"
}

variable "pool_min_capacity" {
  description = "Minimum number of nodes in warm-pool"
  type        = string
  default     = "1"
}

variable "pool_max_capacity" {
  description = "Maximum number of nodes in warm-pool"
  type        = string
  default     = "6"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "The subnets which is a map of availability zones to CIDR blocks"
  type        = map(any)
  default = {
    us-east-1a = "10.0.1.0/24"
    us-east-1b = "10.0.2.0/24"
    us-east-1c = "10.0.3.0/24"
  }
}

variable "key_name" {
  description = "The name of the key for ssh access"
  type        = string
  default     = "ecs_cluster"
}

variable "public_key_path" {
  description = "The local public key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  description = "Additional tags to add to resources"
  type        = map(any)
  default     = {}
}

variable "aws-access-key" {
  type    = string
  default = "*****"
}

variable "aws-secret-key" {
  type    = string
  default = "*****"
}
