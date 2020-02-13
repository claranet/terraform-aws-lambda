terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "nested1" {
  source = "./nested1"
}

module "nested2" {
  source = "./nested2"
}
