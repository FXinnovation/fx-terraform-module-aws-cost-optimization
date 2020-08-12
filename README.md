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

- This modules calls a bash script that calls `terraform` itself and bash. Make sure `bash` is installed and that both software are correctly set in your OS environment paths.
For more information on this limitation, see `data.tf`.
- AWS itself has [some limitations to stop RDS instances](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_StopInstance.html#USER_StopInstance.Limitations).
- Because this module  with AWS lifecycle, it’s possible that an instances end up in an unwanted state.
For example, if optimization is on, someone tried to start an instances, disable optimization and run Terraform, the instance might still be in "Stopping" state, resulting in a "Stopped" state instead of the expected "Running" state.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Error: no lines in file
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning
This repository follows [Semantic Versioning 2.0.0](https://semver.org/)

## Git Hooks
This repository uses [pre-commit](https://pre-commit.com/) hooks.
