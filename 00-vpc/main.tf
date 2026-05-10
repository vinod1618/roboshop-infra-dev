module "vpc"{
    source = "git::https://github.com/vinod1618/terraform-aws-vpc.git?ref=main"
    #source = "../../terraform-aws-vpc"
    project = "roboshop"
    environment = "dev"
    is_peering_required = true
}