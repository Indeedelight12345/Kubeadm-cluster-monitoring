
project_id = "kkgcplabs01-002"
region     = "us-central1"
zone       = "us-central1-a"

network_name = "k8s-network"
subnet_name  = "k8s-subnet"
subnet_cidr  = "10.0.0.0/24"

machine_type = "e2-medium"

ssh_user       = "kubeadmin"
ssh_public_key = "~/.ssh/id_rsa.pub"
