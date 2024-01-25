module "sqs_module" {
  source = "../../modules/sqs"
  sqs_name = "my-sqs"
}

resource "aws_ssm_parameter" "secret_token" {
  name        = "token-ms-1"
  description = "token to check before send to sqs"
  type        = "SecureString"
  value       = var.token
  overwrite   = true
  
  tags = {
    Terraform = "true"
    Environment = "checkpoint"
  }
}

resource "aws_ssm_parameter" "sqs_queue" {
  name        = "my_sqs_queue"
  description = "sqs queue to use to send message then to push on s3 bucket"
  type        = "String"
  value       = module.sqs_module.sqs_url

  tags = {
    Terraform = "true"
    Environment = "checkpoint"
  }
}

resource "aws_ssm_parameter" "S3_bucket" {
  name        = "S3_bucket"
  description = "Name of the bucket to push the message from sqs"
  type        = "String"
  value       = var.S3_bucket_name

  tags = {
    Terraform = "true"
    Environment = "checkpoint"
  }
}

output "ssm_token" {
    value = aws_ssm_parameter.secret_token.name
}