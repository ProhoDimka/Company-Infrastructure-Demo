packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
# ami-0454bb67a751315a3 - ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-20240614
# ami-0c938b21c7e598cd0 - ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-20240701

source "amazon-ebs" "ubuntu" {
  ami_name = "k8s-1-29-6-ubuntu2204-arm64"
  #  description = "source public ami0966f123acb35b919, ubuntu 22.04. Installed containerd 1.7.14, kubeadm 1.29.5, kubelet 1.29.5, kubectl 1.29.5"
  instance_type = "t4g.small"
  region        = "ap-south-1"
  source_ami    = "ami-0c938b21c7e598cd0"
  #   source_ami_filter {
  #     filters = {
  #       name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-202405*"
  #       root-device-type    = "ebs"
  #       virtualization-type = "hvm"
  #     }
  #     most_recent = true
  #     owners = ["099720109477"]
  #   }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "/home/your-linux-user/.ssh/k8s-nodes"
    destination = "/home/ubuntu/.ssh/id_rsa"
  }
  provisioner "file" {
    source      = "/home/your-linux-user/.ssh/k8s-nodes.pub"
    destination = "/home/ubuntu/.ssh/id_rsa.pub"
  }
  provisioner "shell" {
    script       = "k8s_image_preparation.sh"
    pause_before = "10s"
    timeout      = "10s"
  }
}