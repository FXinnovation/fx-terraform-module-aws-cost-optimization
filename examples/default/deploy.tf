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
  source = "github.com/FXinnovation/fx-terraform-module-aws-virtual-machine.git?ref=8.0.0"

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
