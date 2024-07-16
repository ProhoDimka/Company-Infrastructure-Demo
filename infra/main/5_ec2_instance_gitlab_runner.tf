module "ec2_instance_gitlab_runner" {
  # trfp -target module.ec2_pilot_instance
  # trfa -target module.ec2_pilot_instance
  # trfd -target module.ec2_pilot_instance.aws_instance.main -target module.ec2_pilot_instance.aws_route53_record.main

  source                 = "../../modules/ec2_instance"
  region                 = var.region
  vpc_id                 = module.vpc_default.vpc_id
  subnet_id              = module.vpc_default.vpc_subnets_public[0].id
  zone_id_for_dns_record = module.account_dns_zone.zone_id
  account_domain_name    = module.account_dns_zone.zone_id_name

  create_ansible_hosts   = true
  add_iam_creds_to_hosts = true
  use_custom_ip_port     = false
  #   custom_instance_ip     = module.lb_public_common.lb_public_ip
  #   custom_instance_ssh_port = 22

  # Warning for conflicts in case associate_public_ip_address = true
  zone_records = []

#   user_key_path = {
#     private = "/home/your-linux-user/.ssh/id_rsa"
#     public  = "/home/your-linux-user/.ssh/id_rsa.pub"
#   }

  # t4g.medium (arm64 2vcpu/4gb)
  # t4g.small (arm64 2vcpu/2gb)
  # t4g.micro (arm64 2vcpu/1gb)
  # 099720109477 - canonical owner for Ubuntu
  # ami-0454f8914fe93b6ad - ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-20240607

  instance = {
    name                        = "gitlab-master-runner"
    type                        = "t4g.small"
    user                        = "ubuntu"
    aws_ami_id                  = "ami-0454f8914fe93b6ad"
    use_existing_aws_ssh_key    = true
    aws_ssh_key_name            = "main-ssh-key"
    associate_public_ip_address = true
    storage = {
      size = 30
      type = "gp2"
      additional_volumes = []
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
    iam_username = "iam_user_gitlab_runner"
    iam_additional_policy_attachment = []
    iam_additional_user_policy = [
      {
        action = ["*"]
        resource = "*"
      }
    ]
    lb_tg_attachment = []
  }
}