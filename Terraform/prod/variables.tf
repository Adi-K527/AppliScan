variable "access_key" {
  description  = "AWS access key"
  type         = string
}

variable "secret_access_key" {
  description  = "AWS secret access key"
  type         = string
}

variable "ecr_name" {
  description  = "ECR name"
  type         = string
}

variable "models" {
  type    = map(string)
  default = {
    JobStatusModel   = "JobStatusModel"
    NerModel         = "NerModel"
    JobRelatedModel  = "JobRelatedModel"
  }
}