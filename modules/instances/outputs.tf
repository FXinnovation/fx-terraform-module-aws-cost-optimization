####
# CloudWatch rules
####

output "cloudwatch_event_rule_maintain_stop_id" {
  value = element(concat(aws_cloudwatch_event_rule.this_maintain_stop.*.id, [""]), 0)
}

output "cloudwatch_event_rule_maintain_stop_arn" {
  value = element(concat(aws_cloudwatch_event_rule.this_maintain_stop.*.arn, [""]), 0)
}

####
# IAM Roles
####

output "iam_role_ssm_automation_id" {
  value = element(concat(aws_iam_role.this_ssm_automation_iam_role.*.id, [""]), 0)
}

output "iam_role_ssm_automation_arn" {
  value = element(concat(aws_iam_role.this_ssm_automation_iam_role.*.arn, [""]), 0)
}

output "iam_role_cloudwatch_event_id" {
  value = element(concat(aws_iam_role.this_cloudwatch_event_iam_role.*.id, [""]), 0)
}

output "iam_role_cloudwatch_event_arn" {
  value = element(concat(aws_iam_role.this_cloudwatch_event_iam_role.*.arn, [""]), 0)
}

####
# IAM Policies
####

output "iam_policy_ssm_automation_ids" {
  value = compact(concat(aws_iam_policy.this_ssm_automation_iam_policy.*.id, [""]))
}

output "iam_policy_ssm_automation_arns" {
  value = compact(concat(aws_iam_policy.this_ssm_automation_iam_policy.*.arn, [""]))
}

output "iam_policy_cloudwatch_event_ids" {
  value = compact(concat(aws_iam_policy.this_cloudwatch_event_iam_policy.*.id, [""]))
}

output "iam_policy_cloudwatch_event_arns" {
  value = compact(concat(aws_iam_policy.this_cloudwatch_event_iam_policy.*.id, [""]))
}

####
# SSM Association
####

output "ssm_association_id" {
  value = element(concat(aws_ssm_association.this.*.id, [""]), 0)
}
