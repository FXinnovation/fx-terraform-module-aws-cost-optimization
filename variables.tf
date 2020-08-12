
####
# General
####

variable "enabled" {
  description = "Whether or not to enable this entire module or not"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to be shared among all resources of the module."
  default     = {}
}

variable "name" {
  description = "Name that represent the workload or component name that will be cost-optimized."
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where to deploy this module."
  default     = {}
}

variable "prefix" {
  description = "Prefix to use for all the named resources of the module. Mainly use for testing purpose."
  default     = ""
}

####
# IAM Role
####

variable "iam_role_tags" {
  description = "Tags to be shared among all the IAM Role created by the module. Will be merged with var.tags."
  default     = {}
}

####
# EC2 instances
####

variable "ec2_instances_ssm_automation_iam_role_name" {
  description = "Name of the IAM Role to create to allow actions on the EC2 instances by SSM Automation."
  default     = "FXCostOptimizerEC2InstanceActionsForSSMAutomationRole"
}

variable "ec2_instances_ssm_automation_iam_policy_name" {
  description = "Name of the IAM Policy to allow to stop EC2 instances from CloudWatch trigger."
  default     = "FXCostOptimizerEC2InstanceActionsForSSMAutomationPolicy"
}

variable "ec2_instances_cloudwatch_event_iam_role_name" {
  description = "Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the EC2 instances."
  default     = "FXCostOptimizerEC2InstanceActionsForCloudWatchEventsRole"
}

variable "ec2_instances_cloudwatch_event_iam_policy_name" {
  description = "Name of the IAM Policy to create to trigger actions on the EC2 instances by CloudWatch events."
  default     = "FXCostOptimizerEC2InstanceActionsForCloudWatchEventsPolicy"
}

variable "ec2_instances_count" {
  description = "How many EC2 instances to act upon. Cannot compute automatically in Terraform 0.12."
  default     = 0
}

variable "ec2_instances_ids" {
  description = "IDs of the EC2 instances to act upon."
  default     = []
}

####
# RDS
####

variable "rds_instances_ssm_automation_iam_role_name" {
  description = "Name of the IAM Role to create to allow actions on the RDS instances by SSM Automation."
  default     = "FXCostOptimizerRDSInstanceActionsForSSMAutomationRole"
}

variable "rds_instances_ssm_automation_iam_policy_name" {
  description = "Name of the IAM Policy to allow to stop RDS instances from CloudWatch trigger."
  default     = "FXCostOptimizerRDSInstanceActionsForSSMAutomationPolicy"
}

variable "rds_instances_cloudwatch_event_iam_role_name" {
  description = "Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the RDS instances."
  default     = "FXCostOptimizerRDSInstanceActionsForCloudWatchEventsRole"
}

variable "rds_instances_cloudwatch_event_iam_policy_name" {
  description = "Name of the IAM Policy to create to trigger actions on the RDS instances by CloudWatch events."
  default     = "FXCostOptimizerRDSInstanceActionsForCloudWatchEventsPolicy"
}

variable "rds_instances_count" {
  description = "How many RDS instances to act upon. Cannot compute automatically in Terraform 0.12."
  default     = 0
}

variable "rds_instances_ids" {
  description = "IDs of the RDS instances to act upon."
  default     = []
}

####
# SSM Association
####

variable "ssm_association_ec2_instances_stop" {
  description = "Name of the SSM Association to shut down the EC2 instance"
  default     = "FXCostOptimizerEC2Stop"
}

variable "ssm_association_ec2_instances_start" {
  description = "Name of the SSM Association to wake up the EC2 instance"
  default     = "FXCostOptimizerEC2Start"
}

variable "ssm_association_rds_instances_stop" {
  description = "Name of the SSM Association to shut down the RDS instance"
  default     = "FXCostOptimizerRDSStop"
}

variable "ssm_association_rds_instances_start" {
  description = "Name of the SSM Association to wake up the RDS instance"
  default     = "FXCostOptimizerRDSStart"
}

####
# CloudWatch Rule
####

variable "cloudwatch_event_rule_ec2_instance_maintain_stop_name" {
  description = "Name of the CloudWatch Rule that will assure that the cost-optimized EC2 instances stays stopped."
  default     = "FXCostOptimizerEC2MaintainStopRule"
}

variable "cloudwatch_event_rule_rds_instance_maintain_stop_name" {
  description = "Name of the CloudWatch Rule that will assure that the cost-optimized RDS instances stays stopped."
  default     = "FXCostOptimizerRDSMaintainStopRule"
}

variable "cloudwatch_tags" {
  description = "Tags to be shared among all the CloudWatch resources created by the module. Will be merged with var.tags."
  default     = {}
}

####
# SSM Parameters
####

variable "ssm_parameter_toggle_read_only_policy_name" {
  description = "Name of the policy that allows RO access to the toggle SSM Parameter."
  default     = "FXCostOptimizerSSMParameterReadOnlyPolicy"
}

variable "ssm_parameter_toggle_read_write_policy_name" {
  description = "Name of the policy that allows RW access to the toggle SSM Parameter."
  default     = "FXCostOptimizerSSMParameterReadWritePolicy"
}

variable "ssm_parameter_tags" {
  description = "Tags to be shared among all the SSM Parameters created by the module. Will be merged with var.tags."
  default     = {}
}
