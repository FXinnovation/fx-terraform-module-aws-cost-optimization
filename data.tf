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

  program = ["sh", "-c", "terraform show | grep '${data.null_data_source.ssm_parameters_cost_optimization.random}' && echo '{\"ssm\": \"exist\"}' || echo '{\"ssm\": \"notexist\"}'"]
}

// This is used just for the random value it generate, allowing to call this module at different times, multiple times in a deployent
data "null_data_source" "ssm_parameters_cost_optimization" {}

data "aws_ssm_parameter" "toggle" {
  count = var.enabled ? 1 : 0

  name = data.external.this.*.result[0].ssm == "exist" ? "/${format("%s%s", "FXCostOptimizer", var.prefix)}/${var.name}/enable" : "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
