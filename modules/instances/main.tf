locals {
  enabled = var.enabled && var.instances_count > 0

  tags = {
    Terraform  = true
    managed-by = "Terraform"
  }

  ssm_document_type_partial_name = var.type == "EC2" ? var.type : title(lower(var.type))
}

####
# CloudWatch rule
####

resource "aws_cloudwatch_event_rule" "this_maintain_stop" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  name        = var.cloudwatch_event_rule_maintain_stop_name
  description = "Ensures that cost-optimized ${var.type} instances for ${var.name} stays stopped. To prevent this behavior, see the ${var.name} relevent SSM Parameter for cost optimization."

  tags = merge(
    var.tags,
    var.cloudwatch_tags,
    local.tags,
  )

  event_pattern = templatefile("${path.module}/templates/event_${lower(var.type)}.json", {
    instances_ids = var.type == "EC2" ? join("\", \"", var.instances_ids) : "rds:${join("\", \"rds:", var.instances_ids)}"
  })
}

resource "aws_cloudwatch_event_target" "this_maintain_stop" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  rule     = element(aws_cloudwatch_event_rule.this_maintain_stop.*.name, 0)
  arn      = format("%s:$DEFAULT", replace(data.aws_ssm_document.this_maintain_stop.*.arn[0], "document/", "automation-definition/"))
  role_arn = element(aws_iam_role.this_cloudwatch_event_iam_role.*.arn, 0)

  input = <<EOF
{
  "InstanceId": [
    "${join("\", \"", var.instances_ids)}"
  ],
  "AutomationAssumeRole": [
    "${element(aws_iam_role.this_ssm_automation_iam_role.*.arn, 0)}"
  ]
}
EOF
}

####
# IAM Role SSM Automation
####

resource "aws_iam_role" "this_ssm_automation_iam_role" {
  count = local.enabled ? 1 : 0

  name               = format("%s%s", var.prefix, var.instances_ssm_automation_iam_role_name)
  description        = "Allows SSM Automation to perform actions on the ${var.name} ${var.type} instances."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.*.json[0]

  tags = merge(
    var.tags,
    var.iam_role_tags,
    local.tags,
  )
}

data "aws_iam_policy_document" "this_ssm_automation_iam_policy" {
  count = local.enabled ? 1 : 0

  statement {
    sid = "AllowCloudWatchDescribe"

    effect = "Allow"

    actions = [
      "cloudwatch:Describe*",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowInstanceLifecyle"

    effect = "Allow"

    actions = var.type == "EC2" ? [
      format("%s:Describe*", lower(var.type)),
      "ec2:RebootInstances",
      "ec2:StartInstances",
      "ec2:StopInstances",
      ] : [
      format("%s:Describe*", lower(var.type)),
      "rds:RebootDBInstance",
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "rds:StartDBCluster",
      "rds:StopDBInstance",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "this_ssm_automation_iam_policy" {
  count = local.enabled ? 1 : 0

  name        = format("%s%s", var.prefix, var.instances_ssm_automation_iam_policy_name)
  path        = "/"
  description = "Allows SSM Automation to stop ${var.type} instances and describe CloudWatch resources."

  policy = data.aws_iam_policy_document.this_ssm_automation_iam_policy.*.json[0]
}


resource "aws_iam_role_policy_attachment" "this_ssm_automation_iam_policy" {
  count = local.enabled ? 1 : 0

  role       = aws_iam_role.this_ssm_automation_iam_role.*.id[0]
  policy_arn = aws_iam_policy.this_ssm_automation_iam_policy.*.arn[0]
}


####
# IAM Role CloudWatch for SSM Automation
####

resource "aws_iam_role" "this_cloudwatch_event_iam_role" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  name               = format("%s%s", var.prefix, var.instances_cloudwatch_event_iam_role_name)
  description        = "Allows CloudWatch Events to perform actions on the ${var.name} ${var.type} instances via CloudWatch triggers."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.events_assume_role.*.json[0]

  tags = merge(
    var.tags,
    var.iam_role_tags,
    local.tags,
  )
}

data "aws_iam_policy_document" "this_cloudwatch_event_iam_policy" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  statement {
    sid = "AllowSSMAutomation"

    effect = "Allow"

    actions = [
      "ssm:StartAutomationExecution"
    ]

    resources = [
      format("arn:aws:ssm:%s:%s:automation-definition/AWS-Stop%sInstance", data.aws_region.current.*.name[0], data.aws_caller_identity.current.*.account_id[0], var.type),
      format("arn:aws:ssm:%s:%s:automation-definition/AWS-Stop%sInstance:$DEFAULT", data.aws_region.current.*.name[0], data.aws_caller_identity.current.*.account_id[0], var.type),
      format("arn:aws:ssm:%s:%s:automation-definition/AWS-Stop%sInstance:$LATEST", data.aws_region.current.*.name[0], data.aws_caller_identity.current.*.account_id[0], var.type),
    ]
  }

  statement {
    sid = "PassRoleToSSMAutomation"

    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.*.account_id[0], aws_iam_role.this_ssm_automation_iam_role.*.name[0]),
    ]

    condition {
      test     = "StringLikeIfExists"
      values   = ["ssm.amazonaws.com"]
      variable = "iam:PassedToService"
    }
  }
}

resource "aws_iam_policy" "this_cloudwatch_event_iam_policy" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  name        = format("%s%s", var.prefix, var.instances_cloudwatch_event_iam_policy_name)
  path        = "/"
  description = "Allows CloudWatch Events to perform actions on the ${var.name} ${var.type} instances via CloudWatch triggers."

  policy = data.aws_iam_policy_document.this_cloudwatch_event_iam_policy.*.json[0]
}

resource "aws_iam_role_policy_attachment" "this_cloudwatch_event_iam_policy" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  role       = aws_iam_role.this_cloudwatch_event_iam_role.*.id[0]
  policy_arn = aws_iam_policy.this_cloudwatch_event_iam_policy.*.arn[0]
}

####
# SSM Associations
####

resource "aws_ssm_association" "this" {
  count = local.enabled ? var.instances_count : 0

  name = var.enable_cost_optimization ? format("AWS-Stop%sInstance", local.ssm_document_type_partial_name) : format("AWS-Start%sInstance", local.ssm_document_type_partial_name)
  association_name = format(
    "%s%s",
    var.prefix,
    var.enable_cost_optimization ? var.ssm_association_instances_stop : var.ssm_association_instances_start
  )

  parameters = {
    InstanceId           = element(var.instances_ids, count.index),
    AutomationAssumeRole = aws_iam_role.this_ssm_automation_iam_role.*.arn[0]
  }

  max_concurrency                  = 1
  max_errors                       = 1
  automation_target_parameter_name = "InstanceId"

  targets {
    key    = "ParameterValues"
    values = [element(var.instances_ids, count.index)]
  }
}
