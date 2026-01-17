# GCP Project
project_id = "kkgcplabs01-008"

# Location
region = "us-central1"
zone   = "us-central1-a"

# Networking
network_name = "k8s-network"
subnet_name  = "k8s-subnet"
subnet_cidr  = "10.240.0.0/16"

# Compute
machine_type = "e2-medium"

# SSH Access
ssh_user = "ubuntu"
ssh_public_key = "~/.ssh/id_rsa.pub"
