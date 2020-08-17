locals {
  tags = {
    Terraform  = true
    managed-by = "Terraform"
  }

  cost_optimization_parameter_value = element(concat(data.aws_ssm_parameter.toggle.*.value, [""]), 0)
  enable_cost_optimization          = local.cost_optimization_parameter_value == "true" || local.cost_optimization_parameter_value == "True" || local.cost_optimization_parameter_value == 1 || local.cost_optimization_parameter_value == true
}

#####
# EC2 instance
#####

module "ec2_instances" {
  source = "./modules/instances"

  enabled                  = var.enabled
  type                     = "EC2"
  enable_cost_optimization = local.enable_cost_optimization
  tags                     = var.tags
  name                     = var.name
  vpc_id                   = var.vpc_id
  prefix                   = var.prefix

  iam_role_tags = var.iam_role_tags

  instances_ssm_automation_iam_role_name     = var.ec2_instances_ssm_automation_iam_role_name
  instances_ssm_automation_iam_policy_name   = var.ec2_instances_ssm_automation_iam_policy_name
  instances_cloudwatch_event_iam_role_name   = var.ec2_instances_cloudwatch_event_iam_role_name
  instances_cloudwatch_event_iam_policy_name = var.ec2_instances_cloudwatch_event_iam_policy_name
  instances_count                            = var.ec2_instances_count
  instances_ids                              = var.ec2_instances_ids

  ssm_association_instances_stop  = var.ssm_association_ec2_instances_stop
  ssm_association_instances_start = var.ssm_association_ec2_instances_start

  cloudwatch_event_rule_maintain_stop_name = var.cloudwatch_event_rule_ec2_instance_maintain_stop_name
  cloudwatch_tags                          = var.cloudwatch_tags
}


#####
# RDS instance
#####

module "rds_instances" {
  source = "./modules/instances"

  enabled                  = var.enabled
  type                     = "RDS"
  enable_cost_optimization = local.enable_cost_optimization
  tags                     = var.tags
  name                     = var.name
  vpc_id                   = var.vpc_id
  prefix                   = var.prefix

  iam_role_tags = var.iam_role_tags

  instances_ssm_automation_iam_role_name     = var.rds_instances_ssm_automation_iam_role_name
  instances_ssm_automation_iam_policy_name   = var.rds_instances_ssm_automation_iam_policy_name
  instances_cloudwatch_event_iam_role_name   = var.rds_instances_cloudwatch_event_iam_role_name
  instances_cloudwatch_event_iam_policy_name = var.rds_instances_cloudwatch_event_iam_policy_name
  instances_count                            = var.rds_instances_count
  instances_ids                              = var.rds_instances_ids

  ssm_association_instances_stop  = var.ssm_association_rds_instances_stop
  ssm_association_instances_start = var.ssm_association_rds_instances_start

  cloudwatch_event_rule_maintain_stop_name = var.cloudwatch_event_rule_rds_instance_maintain_stop_name
  cloudwatch_tags                          = var.cloudwatch_tags
}

#####
# SSM parameters
#####

module "ssm_parameters_cost_optimization" {
  source = "git::https://scm.dazzlingwrench.fxinnovation.com/fxinnovation-public/terraform-module-aws-ssm-parameters.git?ref=2.0.1"

  enabled = var.enabled

  parameters_count = 1
  prefix           = format("%s%s", "FXCostOptimizer", var.prefix)
  names = [
    "/${var.name}/enable",
  ]
  types = [
    "String",
  ]
  values = [
    false
  ]
  descriptions = [
    "Whether or not to cost-optimize ${var.name} workload. CAREFUL: setting this value to \"true\" might stop or destroy resources.",
  ]

  overwrite = false

  iam_policy_create                 = true
  iam_policy_name_prefix_read_only  = format("%s%s", var.prefix, var.ssm_parameter_toggle_read_only_policy_name)
  iam_policy_name_prefix_read_write = format("%s%s", var.prefix, var.ssm_parameter_toggle_read_write_policy_name)

  tags = merge(
    var.tags,
    {
      Description = "Part of FX Cost Optimizer"
    },
    var.ssm_parameter_tags,
    local.tags,
  )
}
