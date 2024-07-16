variable "region" {
  description = "Region"
  type        = string
  default     = "eu-central-1"
}
variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = ""
}
variable "zone_id_for_dns_record" {
  description = "DNS Zone ID for DNS A-type record"
  type        = string
  default     = ""
}
variable "account_domain_name" {
  description = "account domain zone name"
  type        = string
  default     = null
}

variable "user_key_path" {
  type = object({
    private = string
    public  = string
  })
  default = {
    private = "/home/your-linux-user/.ssh/id_rsa"
    public  = "/home/your-linux-user/.ssh/id_rsa.pub"
  }
}

variable "zone_records" {
  description = "Hosted zone records! Warning for conflicts in case associate_public_ip_address = true"
  type = list(
    object({
      zone_id = string
      name    = string
      type    = string
      ttl     = number
      records = list(string)
    }))
  default = []
}

variable "create_ansible_hosts" {
  type    = bool
  default = false
}


variable "add_iam_creds_to_hosts" {
  type    = bool
  default = false
}


variable "use_custom_ip_port" {
  type    = bool
  default = false
}

variable "custom_instance_ip" {
  type    = string
  default = ""
}

variable "custom_instance_ssh_port" {
  type    = number
  default = 0
}

variable "instance" {
  type = object({
    name                        = string
    type                        = string
    user                        = string
    aws_ami_id                  = string
    use_existing_aws_ssh_key    = bool
    aws_ssh_key_name            = string
    associate_public_ip_address = bool
    storage = object({
      size = number
      type = string
      additional_volumes = list(object({
        enabled     = bool
        device_name = string
        type        = string
        size        = number
      }))
    })
    security_groups_rules = object({
      ingress = list(object({
        from_port = number
        to_port   = number
        protocol  = string
        cidr_blocks = list(string)
      }))
      egress = list(object({
        from_port = number
        to_port   = number
        protocol  = string
        cidr_blocks = list(string)
        ipv6_cidr_blocks = list(string)
      }))
    })
    iam_username = string
    iam_additional_user_policy = list(object({
      action   = list(string)
      resource = string
    }))
    iam_additional_policy_attachment = list(object({
      name = string
      arn  = string
    }))
    lb_tg_attachment = list(object({
      name        = string
      arn         = string
      target_port = string
    }))
  })
  default = {
    name                        = ""
    type                        = "t3a.nano"
    user                        = "ubuntu"
    aws_ami_id = "ami-05e00961530ae1b55" # Mumbai - Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2024-04-11
    use_existing_aws_ssh_key    = true
    aws_ssh_key_name            = "instance_admin_key"
    associate_public_ip_address = false
    storage = {
      size = 20
      type = "gp2"
      additional_volumes = [
        {
          enabled     = false
          device_name = ""
          type        = ""
          size        = 0
        }
      ]
    }
    security_groups_rules = {
      ingress = [
        {
          from_port = 22
          to_port   = 22
          protocol  = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port = 5432
          to_port   = 5423
          protocol  = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port = 80
          to_port   = 80
          protocol  = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port = 443
          to_port   = 443
          protocol  = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        },
      ]
      egress = [
        {
          from_port = 0
          to_port   = 0
          protocol  = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
      ]
    }
    iam_username = "instance_iam_user"
    iam_additional_policy_attachment = [
      {
        name = "admin_access"
        arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
      }
    ]
    iam_additional_user_policy = [
      {
        action = ["ecr-public:*"]
        resource = "*"
      },
    ]
    lb_tg_attachment = [
      {
        name        = "ssh"
        arn         = "arn:1"
        target_port = 22
      }
    ]
  }
}