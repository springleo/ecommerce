# 🛒 Ecommerce 3-Tier Application

This repository contains a containerized **3-tier eCommerce application** consisting of:

- **Frontend** – UI layer
- **Backend** – API / business logic
- **Kubernetes Manifests** – Deployment resources under `k8s/`

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
### 3️⃣ Deploy to Kubernetes (k3s)
```bash
cd ..
kubectl apply -f k8s/
```
###🔎 Verify Deployment
```bash
kubectl get pods
kubectl get svc
```
