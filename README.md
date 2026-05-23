# 🛒 Ecommerce 3-Tier Application

This repository contains a containerized **3-tier eCommerce application** consisting of:

- **Frontend** – UI layer
- **Backend** – API / business logic
- **Kubernetes Manifests** – Deployment resources under `k8s/`
- **Terraform** – IaC 
  
The project is designed for local development and Kubernetes-based deployments.

---

## 📦 Repository Structure
```bash
  .
  ├── backend/
  ├── frontend/
  ├── k8s/
  └── terraform/
```
  
---

## ⚙️ Prerequisites

Make sure you have the following installed:

- Docker
- Kubernetes cluster (Docker Desktop / Minikube / Kind / Cloud cluster)
- kubectl CLI

Verify cluster access:

```bash
kubectl get nodes
```

## 🚀 Local Ramp-Up Guide

Follow these steps to build images locally and deploy to Kubernetes.

### 1️⃣ Build Backend Image

```bash
cd backend
docker build -t backend:local .
```

### 2️⃣ Build Frontend Image
```bash
cd ../frontend
docker build --no-cache -t frontend:local .
```
### 3️⃣ Deploy to local Kubernetes cluster (k3s)
```bash
cd ..
kubectl apply -f k8s/
```
### 🔎 Verify Deployment
```bash
kubectl get pods
kubectl get svc
```

## 🏗️ Terraform Deployment Steps (Executed from WSL Debian)

The AKS infrastructure was provisioned using Terraform from a local **WSL Debian** environment with a remote Azure Storage backend for state management.

### ⚙️ Prerequisites

Ensure the following tools are installed inside WSL:

- Terraform
- Azure CLI (`az`)
- kubectl (optional for later deployment)

Login to Azure:

```bash
az login
```

### 📦 Initialize Terraform
Initialize providers and configure the remote backend (Azure Storage Account + tfstate container):
```bash
cd terraform
terraform init
```
If backend configuration was updated or state migrated:
```bash
terraform init -reconfigure
# or
terraform init -migrate-state
```
### ✅ Validate Configuration
Check Terraform syntax and configuration:
```bash
terraform validate
```

### 🔎 Review Planned Changes
```bash
terraform plan -out=tfplan
```
The plan file is temporary and should not be committed to source control.

### 🚀 Apply Infrastructure Changes
```bash
terraform apply tfplan
```
This step provisions:

- Resource Group
- Virtual Network (Public + Private subnets)
- Network Security Groups
- Private AKS Cluster
- System and User Node Pools


Once done, donot forget to map the optional DNS name with the Public IP, as shown in the below pic.
<img width="938" height="412" alt="image" src="https://github.com/user-attachments/assets/3cc288d4-6487-4831-b812-d2d493c17713" />

At this stage, you should be able to see the frontend service being accessible on your favorite browser, using the DNS name used in the previous step.
<img width="641" height="452" alt="image" src="https://github.com/user-attachments/assets/3c33b23b-5671-4fa7-867a-294e1ba01193" />

You will also be able to see that the DNS name is now being resolved right from your PC.

```
nslookup mmikkili-ecommerce.centralindia.cloudapp.azure.com
Server:         10.255.255.254
Address:        10.255.255.254#53

Non-authoritative answer:
Name:   mmikkili-ecommerce.centralindia.cloudapp.azure.com
Address: 13.71.62.11
```
