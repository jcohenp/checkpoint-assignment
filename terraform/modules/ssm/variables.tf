variable "token" {
  type      = string
  sensitive = true
}

variable "S3_bucket_name" {
  type      = string
}

variable "sqs_queue_name" {
  type      = string
}