data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}
data "aws_region" "current" {
  count = local.enabled ? 1 : 0
}

####
# IAM Roles
####

data "aws_iam_policy_document" "ssm_assume_role" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ssm.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "events_assume_role" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

####
# SSM
####

data "aws_ssm_document" "this_maintain_stop" {
  count = local.enabled && var.enable_cost_optimization ? 1 : 0

  name             = format("AWS-Stop%sInstance", local.ssm_document_type_partial_name)
  document_format  = "YAML"
  document_version = "$DEFAULT"
}
