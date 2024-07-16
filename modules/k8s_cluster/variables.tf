variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-23d2204a"
}

variable "subnet_ids" {
  type = list(string)
  default = ["subnet-bee6d9f4", "subnet-905fa3f9", "subnet-9d9855e6"]
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

variable "image_name_filter" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-202405*"
}

variable "ami_id" {
  description = "Known ami ID"
  type        = string
  default     = "ami-0e156965fedb547a3"
}

variable "additional_cidr_blocks_for_ingress_rules" {
  type = set(string)
  default = []
}

variable "iam_user_name" {
  description = "K8S cluster parameters"
  type        = string
  default     = "k8s-iam-user"
}

variable "k8s" {
  description = "K8S cluster parameters"
  type = object({
    loadbalancer = object({
      dns_name   = string
      private_ip = string
      private_ip_list = list(string)
      public_ip  = string
      target_groups = object({
        api_server_tg_arn      = string
        ingress_http_tg_arn    = string
        ingress_https_tg_arn   = string
        postgresql_main_tg_arn = string
      })
    })
    s3 = object({
      bucket_name = string
    })
    cluster = object(
      {
        name     = string
        dns_name = string
        version = object({
          major = number
          minor = string
          patch = string
        })
        instances = object({
          master = object({
            quantity         = number
            type             = string
            user             = string
            aws_ami_id       = string
            aws_ssh_key_name = string
            storage = object({
              size = number
              type = string
            })
            security_groups_ids = list(string)
          })
          worker = object({
            quantity         = number
            type             = string
            user             = string
            aws_ami_id       = string
            aws_ssh_key_name = string
            storage = object({
              size = number
              type = string
            })
            security_groups_ids = list(string)
          })
        })
      }
    )
  })
  default = {
    loadbalancer = {
      dns_name   = "cluster-1.k8s.dev.example.com"
      private_ip = ""
      private_ip_list = []
      public_ip  = ""
      target_groups = {
        api_server_tg_arn      = ""
        ingress_http_tg_arn    = ""
        ingress_https_tg_arn   = ""
        postgresql_main_tg_arn = ""
      }
    }
    s3 = {
      bucket_name = "k8s.cluster-1.dev.super.project.xyz.com"
    }
    cluster = {
      name     = "cluster-1"
      dns_name = "dev.super.project.xyz.com"
      version = {
        major = "1"
        minor = "29"
        patch = "5"
      }
      instances = {
        master = {
          quantity         = 1
          type             = "t3a.nano"
          user             = "ubuntu"
          aws_ami_id       = "ami-00975bcf7116d087c"
          aws_ssh_key_name = ""
          storage = {
            size = 10
            type = "gp2"
          }
          security_groups_ids = []
        }
        worker = {
          quantity         = 1
          type             = "t3a.nano"
          user             = "ubuntu"
          aws_ami_id       = "ami-00975bcf7116d087c"
          aws_ssh_key_name = ""
          storage = {
            size = 10
            type = "gp2"
          }
          security_groups_ids = []
        }
      }
    }
  }
}