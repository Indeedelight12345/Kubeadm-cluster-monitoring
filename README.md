
# Project: GitOps Kubernetes Cluster on Google Cloud with Terraform, Ansible, Linkerd, ArgoCD & Blue-Green Deployments


## 1. Project Overview & Motivation

This project demonstrates a complete, modern DevOps workflow on **Google Cloud Platform (GCP)**:

- Provision infrastructure using **Terraform modules** (network + compute).
- Use **Ansible** to automate Docker & Kubernetes installation.
- Bootstrap a basic **Kubernetes cluster** with kubeadm (1 master + 1 worker).
- Add **Linkerd** service mesh for observability, traffic management, and mTLS.
- Implement **GitOps** continuous deployment with **ArgoCD**.
- Use **GitHub Actions** to build/push Docker images.
- Achieve **zero-downtime** blue-green deployments via ArgoCD manifests in Git.

### Why This Project?
Kubernetes is the standard for container orchestration, but production-grade setups require:
- Repeatable infrastructure (IaC)
- Automated node provisioning & cluster bootstrap
- Observability & security (service mesh)
- Declarative, automated deployments (GitOps)
- Safe rollout strategies (blue-green)

This project solves common pain points:
- Manual VM setup and Kubernetes installation → error-prone and time-consuming.
- Configuration drift between desired (Git) and actual cluster state.
- Risky deployments without zero-downtime strategies.
- Lack of visibility into microservices traffic & failures.

**Goal achieved**: Fully automated, observable, GitOps-driven Kubernetes cluster on GCP with safe blue-green application rollouts.

## 2. High-Level Architecture

- **Infrastructure**: GCP Compute Engine VMs (1 master + 1 worker) provisioned via Terraform modules.
- **Automation**: Ansible for Docker + Kubernetes setup.
- **Cluster**: kubeadm-based Kubernetes.
- **Service Mesh**: Linkerd (lightweight, adds observability, retries, timeouts, mTLS).
- **CI/CD**: GitHub Actions → build Docker image → push to Docker Hub.
- **GitOps CD**: ArgoCD syncs manifests from Git → deploys application with blue-green strategy.

![architecture diagram](https://miro.medium.com/v2/resize:fit:1200/1*BqhBVtvV8233x6WdlaLOeQ.png)




(Terraform + GCP architecture visuals)






(ArgoCD blue-green deployment workflows)

## 3. Technologies & Tools
- **Cloud**: Google Cloud Platform (Compute Engine)
- **IaC**: Terraform (modular: network & compute modules)
- **Configuration Management**: Ansible
- **Container Runtime**: Docker
- **Kubernetes**: kubeadm (v1.28+)
- **Service Mesh**: Linkerd
- **GitOps/CD**: ArgoCD
- **CI**: GitHub Actions
- **Registry**: Docker Hub

![argocd deployment](https://miro.medium.com/0*oAhSBvre5APnKyGo)

## 4. Step-by-Step Implementation

### Step 1: Infrastructure with Terraform Modules
1. Structure:
   - `modules/network/` → VPC, subnets, firewall rules (allow SSH, kubeadm ports, Linkerd).
   - `modules/compute/` → google_compute_instance resources with startup script or metadata.
   - `main.tf` → calls modules, creates 2 instances (master + worker).

2. Key firewall rules:
   - SSH (22)
   - Kubernetes API (6443)
   - etcd (2379-2380)
   - NodePort/services (30000-32767)
   - Linkerd ports (e.g., 4143, 4191)

3. Apply:
   ```bash
   terraform init
   terraform plan
   terraform apply

### Ansible Automation – Install Docker & Kubernetes
*  create Ansible inventory hosts.ini file  with master & worker IPs.
*  create  playbook to install docker  in both vm
*  install-docker.yml: Install Docker + containerd.
*  install-kubernetes.yml Add Kubernetes repos, install kubeadm/kubelet/kubectl, disable swap, configure sysctl.
*  run ansible playbook to install  docker and kubernates
```
ansible-playbook -i invnetory.ini playbook.yml
ansible-playbook -i invnetory.ini cluster.yml
```
### Ansible playbook 
```
---
- name: Prepare Kubernetes nodes
  hosts: k8s
  become: yes
  vars:
    kube_user: ubuntu

  tasks:
    - name: Update and upgrade apt packages
      apt:
        update_cache: yes
        upgrade: dist

    - name: Install required system packages
      apt:
        name:
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
          - apt-transport-https
        state: present

    - name: Install Docker
      apt:
        name: docker.io
        state: present

    - name: Enable and start Docker
      systemd:
        name: docker
        enabled: yes
        state: started

    - name: Add user to docker group
      user:
        name: "{{ kube_user }}"
        groups: docker
        append: yes

    - name: Allow passwordless sudo for user
      copy:
        dest: "/etc/sudoers.d/{{ kube_user }}"
        content: "{{ kube_user }} ALL=(ALL) NOPASSWD:ALL\n"
        mode: "0440"

```
### Bootstrap Kubernetes Cluster with kubeadm
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# install falnnel for network
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```
### Get join command from output → run on worker
```
sudo kubeadm join <master-ip>:6443 --token ... --discovery-token-ca-cert-hash ...
kubectl get nodes
```
### Install Linkerd Service Mesh
* linkerd  is used to monitor the network
```
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -
linkerd check
```
### Enable mTLS & visualization
```
linkerd viz install | kubectl apply -f -
linkerd viz dashboard &
```
### CI/CD with GitHub Actions & ArgoCD
* install argocd  on the  cluster
*  create a file GitHub Actions workflow (.github/workflows/build-push.yml):
*   build Docker image, push to Docker Hub.

  ![argocd service](https://github.com/Indeedelight12345/GitOps-Based-Kubernetes-Deployment-on-Google-with-Argo-CD/blob/main/picture/Screenshot%202026-01-09%20at%2018.19.36.png)

  
```
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
            username: ${{ secrets.DOCKER_USERNAME }}
            password: ${{ secrets.DOCKER_PASSWORD }} 
      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: yourusername/myapp:latest
```
### Argocd  installtion 
* install argocd   for continous deployment
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### Create blue-green Application in Git repo
* create a yaml file  for deployment
*  ensure the docker image   and tag is correct
*  

![argocd  deployment](https://github.com/Indeedelight12345/GitOps-Based-Kubernetes-Deployment-on-Google-with-Argo-CD/blob/main/picture/Screenshot%202026-01-09%20at%2019.33.12.png)

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: myapp
  labels:
    app: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: rukevweubio/<your-image-name>:latest
        ports:
        - containerPort: 80
        env:
        - name: ENVIRONMENT
          value: "production"
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  namespace: default
spec:
  selector:
    app: my-app
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

```

