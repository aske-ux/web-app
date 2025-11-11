module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.13"
    
    name = "askem-eks-tf-vpc"
    cidr = "192.168.100.0/26"
    
    
    azs  = slice(data.aws_availability_zones.available.names, 0, 2)
    private_subnets = ["192.168.100.0/28", "192.168.100.16/28"]
    public_subnets  = ["192.168.100.32/28", "192.168.100.48/28"]

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