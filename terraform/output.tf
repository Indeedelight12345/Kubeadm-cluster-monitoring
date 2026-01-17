output "master_ip" {
  value = module.master.public_ip
}

output "worker_ip" {
  value = module.worker.public_ip
}
