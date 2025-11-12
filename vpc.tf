module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.13"
    
    name = "askem-eks-tf-vpc"
    cidr = "192.168.100.0/24"

    azs             = slice(data.aws_availability_zones.available.names, 0, 2)
    private_subnets = ["192.168.100.0/26", "192.168.100.64/26"]
    public_subnets  = ["192.168.100.128/26", "192.168.100.192/26"]

    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true

    public_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                      = 1
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"             = 1
    }
}