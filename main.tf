/*
* AWS EC2 Module
* Managed by Praveen Cherukuri
*/

##################################################################################################
###################################### EC2 Instance Module #######################################
##################################################################################################
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["277802554635"] # Image Factory Account
}
#local for tags to be applied to EC2 instance
locals {
  # local to create a map of tags to be applied to EC2 instance by merging the default tags with the user provided tags
  tags = ({
    application = var.application
    environment = var.environment
    project     = var.project
    backup      = var.backup
    owner       = var.owner
    app_owner   = var.app_owner
    description = var.description
  })

  # local to determine if public and private subnets are requested based on the provided required_public_subnet_name and required_private_subnet_name variables
  public_requested  = trimspace(var.required_public_subnet_name) != ""
  private_requested = trimspace(var.required_private_subnet_name) != ""

  # local to determine if both public and private subnets are requested
  both_passed = local.public_requested && local.private_requested

  # local to determine the instance role based on the provided instance_role variable
  instance_role = (var.instance_role != null ? var.instance_role : "V-EC2-SSM")
}

# Data source to get the VPC details based on the provided vpc_name variable
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [upper(var.required_vpc_name)]
  }
}

# # Data source to get the public subnets in the VPC based on the provided vpc_name variable
# data "aws_subnets" "public" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.this.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = [upper("${data.aws_vpc.this.id}-subnet-${var.required_public_subnet_name}-*")]
#   }
# }

# # Data source to get the details of each private subnet
# data "aws_subnet" "public" {
#   for_each = toset(data.aws_subnets.public.ids)

#   id = each.value
# }

# Data source to get the private subnets in the VPC based on the provided vpc_name variable
# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.this.id]
#   }

#   filter {
#     name   = "tag:Name"
#     values = [upper("${data.aws_vpc.this.id}-subnet-${var.required_private_subnet_name}-*")]
#   }
# }

# # Data source to get the details of each private subnet
# data "aws_subnet" "private" {
#   for_each = toset(data.aws_subnets.private.ids)

#   id = each.value
# }

# locals {
#   public_subnets = [
#     for s in data.aws_subnet.public :
#     s if s.availability_zone == var.availability_zone
#   ]

#   private_subnets = [
#     for s in data.aws_subnet.private :
#     s if s.availability_zone == var.availability_zone
#   ]

#   selected_subnet_id = try(
#     local.public_subnets[0].id,
#     local.private_subnets[0].id,
#     null
#   )
# }

data "aws_subnets" "public" {
  count = local.public_requested ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [upper("${data.aws_vpc.this.id}-subnet-${var.required_public_subnet_name}-*")]
  }
}

data "aws_subnet" "public" {
  for_each = local.public_requested ? toset(data.aws_subnets.public[0].ids) : []

  id = each.value
}

data "aws_subnets" "private" {
  count = local.private_requested ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = [upper("${data.aws_vpc.this.id}-subnet-${var.required_private_subnet_name}-*")]
  }
}

data "aws_subnet" "private" {
  for_each = local.private_requested ? toset(data.aws_subnets.private[0].ids) : []

  id = each.value
}

locals {

  public_subnets = local.public_requested ? [
    for s in data.aws_subnet.public :
    s if s.availability_zone == var.availability_zone
  ] : []

  private_subnets = local.private_requested ? [
    for s in data.aws_subnet.private :
    s if s.availability_zone == var.availability_zone
  ] : []

  selected_subnet_id = local.public_requested ? (
    local.public_subnets[0].id
    ) : local.private_requested ? (
    local.private_subnets[0].id
  ) : null
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  instance_type        = var.instance_type
  iam_instance_profile = local.instance_role
  subnet_id            = local.selected_subnet_id
  security_groups      = var.security_groups
  key_name             = var.key_pair
  count                = var.number_of_instances
  user_data = templatefile("${path.root}/scripts/userdata/${var.user_data_template_name}.sh",
    {
      environment = var.environment
    }
  )

  tags = merge({
    Name = upper("${var.environment}-${var.project}-${var.application}-${format("%02d", count.index + 1)}")
  })

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = var.os_disk_size

    tags = merge({
      Name = upper("${var.environment}-${var.project}-${var.application}-osdisk")
    }, local.tags, var.tags)
  }

}

