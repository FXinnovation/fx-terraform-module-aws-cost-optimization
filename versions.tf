terraform {
  required_version = ">= 0.12.29"

  required_providers {
    aws      = ">= 2.58, < 4"
    external = "~> 1.2"
    null     = "~> 2.1"
  }
}
