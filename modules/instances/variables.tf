####
# General
####

variable "enabled" {
  description = "Whether or not to enable this entire module or not"
  type        = bool
  default     = true
}

variable "type" {
  description = "What kind of instances to setup. \"RDS\" or \"EC2\"."
  type        = string
}

variable "enable_cost_optimization" {
  description = "Whether or not to enable cost optimization."
  type        = bool
}

variable "tags" {
  description = "Tags to be shared among all resources of the module."
  type        = object({})
}

variable "name" {
  description = "Name that represent the workload or component name that will be cost-optimized."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where to deploy this module."
  type        = string
}

variable "prefix" {
  description = "Prefix to use for all the named resources of the module. Mainly use for testing purpose."
  type        = string
}

####
# IAM Role
####

variable "iam_role_tags" {
  description = "Tags to be shared among all the IAM Role created by the module. Will be merged with var.tags."
  type        = object({})
}

####
# EC2/RDS instances
####

variable "instances_ssm_automation_iam_role_name" {
  description = "Name of the IAM Role to allow SSM Automation to stop EC2/RDS instances from CloudWatch trigger."
  type        = string
}

variable "instances_ssm_automation_iam_policy_name" {
  description = "Name of the IAM Policy to allow to stop EC2/RDS instances from CloudWatch trigger."
  type        = string
}

variable "instances_cloudwatch_event_iam_role_name" {
  description = "Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the EC2/RDS instances."
  type        = string
}

variable "instances_cloudwatch_event_iam_policy_name" {
  description = "Name of the IAM Policy to create to trigger actions on the EC2/RDS instances by CloudWatch events."
  type        = string
}

variable "instances_count" {
  description = "How many EC2/RDS instances to act upon. Cannot compute automatically in Terraform 0.12."
  default     = 0
}

variable "instances_ids" {
  description = "IDs of the EC2/RDS instances to act upon."
  type        = list(string)
}

####
# SSM Association
####

variable "ssm_association_instances_stop" {
  description = "Name of the SSM Association to shut down the EC2/RDS instance"
  type        = string
}

variable "ssm_association_instances_start" {
  description = "Name of the SSM Association to wake up the EC2/RDS instance"
  type        = string
}


####
# CloudWatch Rule
####

variable "cloudwatch_event_rule_maintain_stop_name" {
  description = "Name of the CloudWatch Rule that will assure that the cost-optimized instances stays stopped."
  type        = string
}

variable "cloudwatch_tags" {
  description = "Tags to be shared among all the CloudWatch resources created by the module. Will be merged with var.tags."
  type        = object({})
}
