resource "random_string" "this" {
  length  = 6
  upper   = false
  special = false
  number  = false
}

data "aws_vpc" "example" {
  default = true
}

data "aws_ssm_parameter" "ami" {

  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

module "example_instances" {
  source = "git::ssh://git@scm.dazzlingwrench.fxinnovation.com:2222/fxinnovation-public/terraform-module-aws-virtual-machine.git?ref=8.0.0"

  instance_count = 2
  name           = "${random_string.this.result}tftest"
  ami            = data.aws_ssm_parameter.ami.value

  instance_type = "t3.nano"

  tags = {
    tftest = true
  }
}

resource "aws_db_instance" "example" {
  count = 1

  allocated_storage    = 20
  multi_az             = false
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

#####
# Example
# Shows how to:
# - cost optimize EC2 instances
# - cost optimize RDS instance
#####

module "example" {
  source = "../.."

  prefix = random_string.this.result

  name   = "tftest"
  vpc_id = data.aws_vpc.example.id

  ec2_instances_count = 2
  ec2_instances_ids   = module.example_instances.ec2_ids

  rds_instances_count = 1
  rds_instances_ids   = aws_db_instance.example.*.id

  tags = {
    tftest = true
  }
}

#####
# Example 2
# Shows how to:
# - call the module a second time, to make sure cost optimization can be called multiple times
#####

module "example2" {
  source = "../.."

  prefix = random_string.this.result

  name   = "tftest 2"
  vpc_id = data.aws_vpc.example.id

  tags = {
    tftest = true
  }
}
