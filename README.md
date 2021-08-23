# Terraform module: cost optimization

> **For our dear end users**: to disable what this module does, use the SSM Parameter toggle under `/FXCostOptimizer/` in your AWS Account.
> Do not try to modify the code here to disable anything.
> Do not try to manually destroy resources neither.

By using this module, you can optimize the cost of an AWS infrastructure by:

- Accessing a key/value store toggle so you can choose programmatically to destroy or stop resources
- Letting the module handle stopping EC2/RDS instances according to the toggle
- Ensure that the destroy state or the stopped state is kept even after manual operations
- Setup schedule jobs to automatically stop resources at given time windows (NOT IMPLEMENTED YET)

## Usage scenario

1. This module creates a toggle SSM Parameter for cost optimization. This SSM Parameter value is left untouched by Terraform.
2. This module will read the value of the SSM Parameter to decide whether or not to optimize the workload. Meaning: instances or data might be stopped or destroyed, depending on the variables user has set in this module.
3. If SSM Parameter toggle value has changes since last apply, Terraform will take care of optimizing or restoring the normal state, according to the boolean.

## Notes

- The module will advertise the value of the SSM Parameter for cost optimization. Thus, you can make your own custom optimizations according to the value.
- The module will create read only and read/write policy to get access to the SSM Parameter. This allows automations for changing the value of the SSM parameter.
- This module can be disabled. It is highly recommended to disable this module in production environment so toggle nor any resources regarding cost optimization are created.

## Limitations

- This modules calls a shell script that calls `terraform` itself. Make sure `sh` is installed and that both software are correctly set in your OS environment paths.
For more information on this limitation, see `data.tf`.
- It’s not yet possible to use or import and external SSM Parameter to controle cost optimization.
- AWS itself has [some limitations to stop RDS instances](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_StopInstance.html#USER_StopInstance.Limitations).
- Because this module  with AWS lifecycle, it’s possible that an instances end up in an unwanted state.
For example, if optimization is on, someone tried to start an instances, disable optimization and run Terraform, the instance might still be in "Stopping" state, resulting in a "Stopped" state instead of the expected "Running" state.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.5 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.5 |
| <a name="provider_external"></a> [external](#provider\_external) | >= 2.1 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instances"></a> [ec2\_instances](#module\_ec2\_instances) | ./modules/instances | n/a |
| <a name="module_rds_instances"></a> [rds\_instances](#module\_rds\_instances) | ./modules/instances | n/a |
| <a name="module_ssm_parameters_cost_optimization"></a> [ssm\_parameters\_cost\_optimization](#module\_ssm\_parameters\_cost\_optimization) | git::https://scm.dazzlingwrench.fxinnovation.com/fxinnovation-public/terraform-module-aws-ssm-parameters.git | 2.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.toggle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [external_external.this](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [null_data_source.this](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_event_rule_ec2_instance_maintain_stop_name"></a> [cloudwatch\_event\_rule\_ec2\_instance\_maintain\_stop\_name](#input\_cloudwatch\_event\_rule\_ec2\_instance\_maintain\_stop\_name) | Name of the CloudWatch Rule that will assure that the cost-optimized EC2 instances stays stopped. | `string` | `"FXCostOptimizerEC2MaintainStopRule"` | no |
| <a name="input_cloudwatch_event_rule_rds_instance_maintain_stop_name"></a> [cloudwatch\_event\_rule\_rds\_instance\_maintain\_stop\_name](#input\_cloudwatch\_event\_rule\_rds\_instance\_maintain\_stop\_name) | Name of the CloudWatch Rule that will assure that the cost-optimized RDS instances stays stopped. | `string` | `"FXCostOptimizerRDSMaintainStopRule"` | no |
| <a name="input_cloudwatch_tags"></a> [cloudwatch\_tags](#input\_cloudwatch\_tags) | Tags to be shared among all the CloudWatch resources created by the module. Will be merged with var.tags. | `map` | `{}` | no |
| <a name="input_ec2_instances_cloudwatch_event_iam_policy_name"></a> [ec2\_instances\_cloudwatch\_event\_iam\_policy\_name](#input\_ec2\_instances\_cloudwatch\_event\_iam\_policy\_name) | Name of the IAM Policy to create to trigger actions on the EC2 instances by CloudWatch events. | `string` | `"FXCostOptimizerEC2InstanceActionsForCloudWatchEventsPolicy"` | no |
| <a name="input_ec2_instances_cloudwatch_event_iam_role_name"></a> [ec2\_instances\_cloudwatch\_event\_iam\_role\_name](#input\_ec2\_instances\_cloudwatch\_event\_iam\_role\_name) | Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the EC2 instances. | `string` | `"FXCostOptimizerEC2InstanceActionsForCloudWatchEventsRole"` | no |
| <a name="input_ec2_instances_count"></a> [ec2\_instances\_count](#input\_ec2\_instances\_count) | How many EC2 instances to act upon. Cannot compute automatically in Terraform 0.12. | `number` | `0` | no |
| <a name="input_ec2_instances_ids"></a> [ec2\_instances\_ids](#input\_ec2\_instances\_ids) | IDs of the EC2 instances to act upon. | `list` | `[]` | no |
| <a name="input_ec2_instances_ssm_automation_iam_policy_name"></a> [ec2\_instances\_ssm\_automation\_iam\_policy\_name](#input\_ec2\_instances\_ssm\_automation\_iam\_policy\_name) | Name of the IAM Policy to allow to stop EC2 instances from CloudWatch trigger. | `string` | `"FXCostOptimizerEC2InstanceActionsForSSMAutomationPolicy"` | no |
| <a name="input_ec2_instances_ssm_automation_iam_role_name"></a> [ec2\_instances\_ssm\_automation\_iam\_role\_name](#input\_ec2\_instances\_ssm\_automation\_iam\_role\_name) | Name of the IAM Role to create to allow actions on the EC2 instances by SSM Automation. | `string` | `"FXCostOptimizerEC2InstanceActionsForSSMAutomationRole"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether or not to enable this entire module or not | `bool` | `true` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | Tags to be shared among all the IAM Role created by the module. Will be merged with var.tags. | `map` | `{}` | no |
| <a name="input_manual_random_value"></a> [manual\_random\_value](#input\_manual\_random\_value) | A random value that must be unique, manually provided (no build-in function can be used) and with a minimum length of 10. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name that represent the workload or component name that will be cost-optimized. | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use for all the named resources of the module. Mainly use for testing purpose. | `string` | `""` | no |
| <a name="input_rds_instances_cloudwatch_event_iam_policy_name"></a> [rds\_instances\_cloudwatch\_event\_iam\_policy\_name](#input\_rds\_instances\_cloudwatch\_event\_iam\_policy\_name) | Name of the IAM Policy to create to trigger actions on the RDS instances by CloudWatch events. | `string` | `"FXCostOptimizerRDSInstanceActionsForCloudWatchEventsPolicy"` | no |
| <a name="input_rds_instances_cloudwatch_event_iam_role_name"></a> [rds\_instances\_cloudwatch\_event\_iam\_role\_name](#input\_rds\_instances\_cloudwatch\_event\_iam\_role\_name) | Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the RDS instances. | `string` | `"FXCostOptimizerRDSInstanceActionsForCloudWatchEventsRole"` | no |
| <a name="input_rds_instances_count"></a> [rds\_instances\_count](#input\_rds\_instances\_count) | How many RDS instances to act upon. Cannot compute automatically in Terraform 0.12. | `number` | `0` | no |
| <a name="input_rds_instances_ids"></a> [rds\_instances\_ids](#input\_rds\_instances\_ids) | IDs of the RDS instances to act upon. | `list` | `[]` | no |
| <a name="input_rds_instances_ssm_automation_iam_policy_name"></a> [rds\_instances\_ssm\_automation\_iam\_policy\_name](#input\_rds\_instances\_ssm\_automation\_iam\_policy\_name) | Name of the IAM Policy to allow to stop RDS instances from CloudWatch trigger. | `string` | `"FXCostOptimizerRDSInstanceActionsForSSMAutomationPolicy"` | no |
| <a name="input_rds_instances_ssm_automation_iam_role_name"></a> [rds\_instances\_ssm\_automation\_iam\_role\_name](#input\_rds\_instances\_ssm\_automation\_iam\_role\_name) | Name of the IAM Role to create to allow actions on the RDS instances by SSM Automation. | `string` | `"FXCostOptimizerRDSInstanceActionsForSSMAutomationRole"` | no |
| <a name="input_ssm_association_ec2_instances_start"></a> [ssm\_association\_ec2\_instances\_start](#input\_ssm\_association\_ec2\_instances\_start) | Name of the SSM Association to wake up the EC2 instance | `string` | `"FXCostOptimizerEC2Start"` | no |
| <a name="input_ssm_association_ec2_instances_stop"></a> [ssm\_association\_ec2\_instances\_stop](#input\_ssm\_association\_ec2\_instances\_stop) | Name of the SSM Association to shut down the EC2 instance | `string` | `"FXCostOptimizerEC2Stop"` | no |
| <a name="input_ssm_association_rds_instances_start"></a> [ssm\_association\_rds\_instances\_start](#input\_ssm\_association\_rds\_instances\_start) | Name of the SSM Association to wake up the RDS instance | `string` | `"FXCostOptimizerRDSStart"` | no |
| <a name="input_ssm_association_rds_instances_stop"></a> [ssm\_association\_rds\_instances\_stop](#input\_ssm\_association\_rds\_instances\_stop) | Name of the SSM Association to shut down the RDS instance | `string` | `"FXCostOptimizerRDSStop"` | no |
| <a name="input_ssm_parameter_tags"></a> [ssm\_parameter\_tags](#input\_ssm\_parameter\_tags) | Tags to be shared among all the SSM Parameters created by the module. Will be merged with var.tags. | `map` | `{}` | no |
| <a name="input_ssm_parameter_toggle_read_only_policy_name"></a> [ssm\_parameter\_toggle\_read\_only\_policy\_name](#input\_ssm\_parameter\_toggle\_read\_only\_policy\_name) | Name of the policy that allows RO access to the toggle SSM Parameter. | `string` | `"FXCostOptimizerSSMParameterReadOnlyPolicy"` | no |
| <a name="input_ssm_parameter_toggle_read_write_policy_name"></a> [ssm\_parameter\_toggle\_read\_write\_policy\_name](#input\_ssm\_parameter\_toggle\_read\_write\_policy\_name) | Name of the policy that allows RW access to the toggle SSM Parameter. | `string` | `"FXCostOptimizerSSMParameterReadWritePolicy"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be shared among all resources of the module. | `map` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where to deploy this module. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_optimization_enabled"></a> [cost\_optimization\_enabled](#output\_cost\_optimization\_enabled) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning
This repository follows [Semantic Versioning 2.0.0](https://semver.org/)

## Git Hooks
This repository uses [pre-commit](https://pre-commit.com/) hooks.
