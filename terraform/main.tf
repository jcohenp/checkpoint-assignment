module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "checkpoint-assignment"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  tags = {
    Terraform = "true"
    Environment = "checkpoint"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

module "s3_module" {
  source = "./modules/s3"
  bucket_name = "messages-bucket-checkpoint-assignment"
}

output "main_s3_bucket_name" {
  value = module.s3_module.s3_bucket_name
}

module "eks_module" {
  source = "./modules/eks"
  cluster_name = "my-eks-cluster"
  subnet_ids = ["subnet-1a02466a", "subnet-5ccdc07b", "subnet-e1d1a3ec"]
  vpc_id = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks_module.eks_cluster_name
}

module "sqs_module" {
  source = "./modules/sqs"
  sqs_name = "my-sqs"
}

output "sqs_queue_name" {
  value = module.sqs_module.sqs_queue_name
}

module "ssm_module" {
  source = "./modules/ssm"
  token = var.token
  S3_bucket_name = "messages-bucket-checkpoint-assignment"
  sqs_queue_name = "my_sqs"
}

output "ssm_token" {
  value = module.ssm_module.ssm_token
}

# Null resource to apply Kubernetes manifests
resource "null_resource" "apply_kubernetes_manifests" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ./modules/kubernetes --server=https://localhost.localstack.cloud:4510 --insecure-skip-tls-verify"
  }
}

