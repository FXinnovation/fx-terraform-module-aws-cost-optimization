####
# Toggle SSM Parameter
####

// This solution (data external and null_data_source) circumvent the lack of lifecycle for data sources. Explanation below.
// What is impossible as 2020-08-10: use a data source to create some resources while the data source depends on another resource:
// Resource A > Data Source > Resource B
// "depends_on" on the data source works correctly but it breaks idempotency which is never acceptable and does not pass CI/CD tests anyway.
// The workaround: The current statefile is read via sh. If the SSM Parameter exists, returns "exist", if not, returns "notexist".
// The workaround: Then, the data source SSM Parameter use a condition on this return to get the real value or a dummy AMI value that we don't use.
// This workaround needs a local system execution with sh and gnu-tools installed.
data "external" "this" {
  count = var.enabled ? 1 : 0

  program = ["sh", "-c", "terraform show | grep -q '\"fx_innovation_cost_opti_random_datasource\" = \"${var.manual_random_value}\"' && echo '{\"ssm\": \"exist\"}' || echo '{\"ssm\": \"notexist\"}'"]
}

data "null_data_source" "this" {
  count = var.enabled ? 1 : 0

  inputs = {
    fx_innovation_cost_opti_random_datasource = var.manual_random_value
  }
}

data "aws_ssm_parameter" "toggle" {
  count = var.enabled ? 1 : 0

  name = data.external.this.0.result.ssm == "exist" ? "/${format("%s%s", "FXCostOptimizer", var.prefix)}/${local.name_without_spaces}/enable" : "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
