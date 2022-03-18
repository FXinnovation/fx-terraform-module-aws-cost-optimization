# Default example

## Usage

```
# terraform init
# terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 2, < 4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.58, < 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | > 2, < 4 >= 2.58, < 4 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_example"></a> [example](#module\_example) | ../.. | n/a |
| <a name="module_example2"></a> [example2](#module\_example2) | ../.. | n/a |
| <a name="module_example_instances"></a> [example\_instances](#module\_example\_instances) | git::ssh://git@github.com/FXinnovation/fx-terraform-module-aws-virtual-machine.git | 8.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_test"></a> [test](#output\_test) | n/a |
| <a name="output_test22"></a> [test22](#output\_test22) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
