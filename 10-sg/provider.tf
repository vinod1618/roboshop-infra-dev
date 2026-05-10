terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0" # terraform aws provider version
    }
  }

  
  backend "s3" {
    bucket         = "vinod-remote-statefile-devops-aws-dev" # replace with your unique bucket name
    key            = "roboshop-dev-sg" # here we have to put the name in which the state file want to store
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }

}

provider "aws" {
  region = "us-east-1"
}