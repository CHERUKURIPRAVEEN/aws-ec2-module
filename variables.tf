variable "region" {
  description = "region details"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "default tags"
  type        = map(string)
  default = {
    "env" = "Dev"
  }
}

variable "ami_name" {
  description = "AMI Name"
  type        = string
  default     = "ubuntu"
}

variable "os" {
  description = "Operating System"
  type        = string

  validation {
    condition     = contains(["ubuntu22", "ubuntu24", "ubuntu26"], var.os)
    error_message = "Invalid OS."
  }
}

variable "application" {
  description = "Application tag value for the EC2 instance. Minimum of 8 characters."
  type        = string

  validation {
    condition     = length(var.application) > 7
    error_message = "application value should be minimum of 8 characters"
  }
}

variable "environment" {
  description = "Environment of the EC2 instance. Possible values: 'Dev','Qa','Stage','PreProd','Production'"
  type        = string
  default     = "Dev"

  validation {
    condition     = contains(["Dev", "Qa", "Stage", "PreProd", "Production"], var.environment)
    error_message = "Environment should be 'Dev','Qa','Stage','PreProd','Production'"
  }
}

variable "project" {
  description = "Project for which EC2 instance is being created"
  type        = string
  default     = ""

  validation {
    condition     = length(var.project) > 7 || var.project == ""
    error_message = "Project value should be minimum of 8 characters or empty"
  }
}

variable "backup" {
  description = "Backup to which the EC2 instance belongs. Possible values: 'N/A', 'NonProd', 'Prod'"
  type        = string
  default     = "N/A"

  validation {
    condition     = contains(["N/A", "NonProd", "Prod"], var.backup)
    error_message = "Backup must be only these values 'N/A', 'NonProd', 'Prod'."
  }
}

variable "owner" {
  description = "Email address of the EC2 instance owner."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@veen\\.com$", var.owner))
    error_message = "Owner email must be a valid @veen.com address."
  }
}

variable "app_owner" {
  description = "Email address of the application owner."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@veen\\.com$", var.app_owner))
    error_message = "Application owner email must be a valid @veen.com address."
  }
}

variable "description" {
  description = "Description for which EC2 instance is being created"
  type        = string

  validation {
    condition     = length(var.description) > 9
    error_message = "Description value should be minimum of 10 characters"
  }
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "vpc_name" {
  description = "vpc name"
  type        = string
  default     = "MANAGEMENT_VPC"

  validation {
    condition     = contains(["MANAGEMENT_VPC", "DEV_VPC", "STAGE_VPC", "PREPROD_VPC", "PRODUCTION_VPC"], var.vpc_name)
    error_message = "VPC name should be one of the allowed values."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_role" {
  description = "Instance role for the EC2 instance"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "Security Group to be included on the EC2 instance."
  type        = list(any)
  default     = []
}

variable "key_pair" {
  description = "Keypair to be used on the EC2 instance."
  type        = string
  default     = "MANAGED_KEY"
}


variable "user_data_template_name" {
  description = "Name of the user data template file (without extension)"
  type        = string
  default     = "userdata"
}

variable "os_disk_size" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30
}
