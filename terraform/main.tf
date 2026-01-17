module "network" {
  source       = "./modules/networks"
  network_name = var.network_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  region       = var.region
}

module "master" {
  source         = "./modules/compute"
  name           = "k8s-master"
  machine_type   = var.machine_type
  zone           = var.zone
  image          = var.image
  network_id     = module.network.network_id
  subnet_id      = module.network.subnet_id
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
  tags           = ["k8s", "master"]
}

module "worker" {
  source         = "./modules/compute"
  name           = "k8s-worker"
  machine_type   = var.machine_type
  zone           = var.zone
  image          = var.image
  network_id     = module.network.network_id
  subnet_id      = module.network.subnet_id
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
  tags           = ["k8s", "worker"]
}
