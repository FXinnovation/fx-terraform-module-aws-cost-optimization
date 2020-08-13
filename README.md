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
- AWS itself has [some limitations to stop RDS instances](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_StopInstance.html#USER_StopInstance.Limitations).
- Because this module  with AWS lifecycle, it’s possible that an instances end up in an unwanted state.
For example, if optimization is on, someone tried to start an instances, disable optimization and run Terraform, the instance might still be in "Stopping" state, resulting in a "Stopped" state instead of the expected "Running" state.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.29 |
| aws | ~>2.58 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>2.58 |
| external | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_event\_rule\_ec2\_instance\_maintain\_stop\_name | Name of the CloudWatch Rule that will assure that the cost-optimized EC2 instances stays stopped. | `string` | `"FXCostOptimizerEC2MaintainStopRule"` | no |
| cloudwatch\_event\_rule\_rds\_instance\_maintain\_stop\_name | Name of the CloudWatch Rule that will assure that the cost-optimized RDS instances stays stopped. | `string` | `"FXCostOptimizerRDSMaintainStopRule"` | no |
| cloudwatch\_tags | Tags to be shared among all the CloudWatch resources created by the module. Will be merged with var.tags. | `map` | `{}` | no |
| ec2\_instances\_cloudwatch\_event\_iam\_policy\_name | Name of the IAM Policy to create to trigger actions on the EC2 instances by CloudWatch events. | `string` | `"FXCostOptimizerEC2InstanceActionsForCloudWatchEventsPolicy"` | no |
| ec2\_instances\_cloudwatch\_event\_iam\_role\_name | Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the EC2 instances. | `string` | `"FXCostOptimizerEC2InstanceActionsForCloudWatchEventsRole"` | no |
| ec2\_instances\_count | How many EC2 instances to act upon. Cannot compute automatically in Terraform 0.12. | `number` | `0` | no |
| ec2\_instances\_ids | IDs of the EC2 instances to act upon. | `list` | `[]` | no |
| ec2\_instances\_ssm\_automation\_iam\_policy\_name | Name of the IAM Policy to allow to stop EC2 instances from CloudWatch trigger. | `string` | `"FXCostOptimizerEC2InstanceActionsForSSMAutomationPolicy"` | no |
| ec2\_instances\_ssm\_automation\_iam\_role\_name | Name of the IAM Role to create to allow actions on the EC2 instances by SSM Automation. | `string` | `"FXCostOptimizerEC2InstanceActionsForSSMAutomationRole"` | no |
| enabled | Whether or not to enable this entire module or not | `bool` | `true` | no |
| iam\_role\_tags | Tags to be shared among all the IAM Role created by the module. Will be merged with var.tags. | `map` | `{}` | no |
| name | Name that represent the workload or component name that will be cost-optimized. | `string` | `""` | no |
| prefix | Prefix to use for all the named resources of the module. Mainly use for testing purpose. | `string` | `""` | no |
| rds\_instances\_cloudwatch\_event\_iam\_policy\_name | Name of the IAM Policy to create to trigger actions on the RDS instances by CloudWatch events. | `string` | `"FXCostOptimizerRDSInstanceActionsForCloudWatchEventsPolicy"` | no |
| rds\_instances\_cloudwatch\_event\_iam\_role\_name | Name of the IAM Role to allow CloudWatch Events to trigger SSM Automation actions on the RDS instances. | `string` | `"FXCostOptimizerRDSInstanceActionsForCloudWatchEventsRole"` | no |
| rds\_instances\_count | How many RDS instances to act upon. Cannot compute automatically in Terraform 0.12. | `number` | `0` | no |
| rds\_instances\_ids | IDs of the RDS instances to act upon. | `list` | `[]` | no |
| rds\_instances\_ssm\_automation\_iam\_policy\_name | Name of the IAM Policy to allow to stop RDS instances from CloudWatch trigger. | `string` | `"FXCostOptimizerRDSInstanceActionsForSSMAutomationPolicy"` | no |
| rds\_instances\_ssm\_automation\_iam\_role\_name | Name of the IAM Role to create to allow actions on the RDS instances by SSM Automation. | `string` | `"FXCostOptimizerRDSInstanceActionsForSSMAutomationRole"` | no |
| ssm\_association\_ec2\_instances\_start | Name of the SSM Association to wake up the EC2 instance | `string` | `"FXCostOptimizerEC2Start"` | no |
| ssm\_association\_ec2\_instances\_stop | Name of the SSM Association to shut down the EC2 instance | `string` | `"FXCostOptimizerEC2Stop"` | no |
| ssm\_association\_rds\_instances\_start | Name of the SSM Association to wake up the RDS instance | `string` | `"FXCostOptimizerRDSStart"` | no |
| ssm\_association\_rds\_instances\_stop | Name of the SSM Association to shut down the RDS instance | `string` | `"FXCostOptimizerRDSStop"` | no |
| ssm\_parameter\_tags | Tags to be shared among all the SSM Parameters created by the module. Will be merged with var.tags. | `map` | `{}` | no |
| ssm\_parameter\_toggle\_read\_only\_policy\_name | Name of the policy that allows RO access to the toggle SSM Parameter. | `string` | `"FXCostOptimizerSSMParameterReadOnlyPolicy"` | no |
| ssm\_parameter\_toggle\_read\_write\_policy\_name | Name of the policy that allows RW access to the toggle SSM Parameter. | `string` | `"FXCostOptimizerSSMParameterReadWritePolicy"` | no |
| tags | Tags to be shared among all resources of the module. | `map` | `{}` | no |
| vpc\_id | ID of the VPC where to deploy this module. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cost\_optimization\_enabled | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning
This repository follows [Semantic Versioning 2.0.0](https://semver.org/)

## Git Hooks
This repository uses [pre-commit](https://pre-commit.com/) hooks.
