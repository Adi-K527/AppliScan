variable "models" {
  type    = map(string)
  default = {
    JobStatusModel   = "JobStatusModel"
    NerModel         = "NerModel"
  }
}

variable "job_status_model_arn" {
  description = "ARN for job status model lambda function"
  type        = string
  
}

variable "ner_model_arn" {
  description = "ARN for ner model lambda function"
  type        = string
}

variable "job_related_function_name" {
  description = "Name of the job related function"
  type        = string
}