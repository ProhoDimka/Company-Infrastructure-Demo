output "masters" {
  value = {
    for master in aws_instance.k8s_masters : master.id => {
      private_dns_name = master.private_dns
      private_ip = master.private_ip
    }
  }
}

output "workers" {
  value = {
    for worker in aws_instance.k8s_workers : worker.id => {
      private_dns_name = worker.private_dns
      private_ip = worker.private_ip
    }
  }
}