module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.13"
    
    name = "askem-eks-tf-vpc"
    cidr = "192.168.100.0/24"  # ← 256 IP

    azs             = slice(data.aws_availability_zones.available.names, 0, 2)
    private_subnets = ["192.168.100.0/26", "192.168.101.0/26"]  # 2×62 = 124
    public_subnets  = ["192.168.102.0/26", "192.168.103.0/26"]  # 2×62 = 124

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