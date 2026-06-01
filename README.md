# The Redemption Platform

## Cloud Engineer Technical Assessment Submission

Author: Myint Hein Kyaw

---

# Overview

This repository contains my submission for the Cloud Engineer Technical Assessment.

The solution demonstrates a production-ready cloud architecture for The Redemption Platform, a global hotel loyalty point redemption system designed to support secure, scalable, and highly available redemption transactions.

The platform is built on AWS and follows the AWS Well-Architected Framework with a focus on:

* Reliability
* Scalability
* Security
* Operational Excellence
* Cost Optimization

The implementation includes Infrastructure as Code (Terraform), Kubernetes deployment on Amazon EKS, GitOps workflows, observability, autoscaling, and disaster recovery capabilities.

---

# Architecture Highlights

* Multi-AZ Deployment (ap-southeast-1)
* Amazon EKS
* Amazon Aurora PostgreSQL
* Amazon ElastiCache Redis
* Amazon CloudFront
* AWS WAF
* GitOps with ArgoCD
* Progressive Delivery with Argo Rollouts
* Horizontal Pod Autoscaler (HPA)
* KEDA Event-Driven Autoscaling
* Karpenter Node Autoscaling
* Prometheus Monitoring
* Alertmanager Alerting
* Velero Backup and Recovery
* AWS Backup

---

# AWS Well-Architected Mapping

| Pillar                 | Implementation                                     |
| ---------------------- | -------------------------------------------------- |
| Reliability            | Multi-AZ EKS, Aurora PostgreSQL, Redis Replication |
| Scalability            | HPA, KEDA, Karpenter, EKS Managed Node Groups      |
| Security               | WAF, IAM Roles, Security Groups, Private Subnets   |
| Operational Excellence | GitOps with ArgoCD, Terraform, Monitoring          |
| Cost Optimization      | Karpenter, Spot Capacity Support, Autoscaling      |
| Observability          | Prometheus, Alertmanager, ServiceMonitor           |
| Disaster Recovery      | Velero Backups, AWS Backup                         |

# Architecture Diagram

Architecture diagram is available at:

architecture/redemption-architecture.png

---

# Repository Structure

redemption-cloud-engineer-assessment/

├── README.md
├── architecture/
├── docs/
├── kubernetes/
│   ├── apps/
│   ├── autoscaling/
│   ├── dr/
│   ├── gitops/
│   └── observability/
└── terraform/


# Infrastructure Components

## Terraform

Infrastructure resources are provisioned using Terraform.

### Networking

* Amazon VPC
* Public Subnets
* Private Application Subnets
* Private Data Subnets
* NAT Gateways
* VPC Endpoints

### Compute

* Amazon EKS
* Managed Node Groups
* Karpenter

### Database

* Amazon Aurora PostgreSQL
* Amazon ElastiCache Redis

### Security

* AWS WAF
* IAM Roles and Policies
* Security Groups

### Edge & Content Delivery

* Amazon CloudFront
* Application Load Balancer

### Monitoring & Operations

* Amazon Managed Prometheus
* Amazon Managed Grafana
* CloudWatch
* SNS Notifications

### Backup & Recovery

* AWS Backup
* Velero

---

# Kubernetes Components

The Kubernetes deployment manifests include:

### Application Layer

* Namespace
* Deployment
* Service
* Ingress
* ConfigMap
* Secret

### Autoscaling

* Horizontal Pod Autoscaler (HPA)
* KEDA ScaledObject
* Karpenter NodePool
* EC2NodeClass

### GitOps

* ArgoCD Application
* Argo Rollout

### Observability

* ServiceMonitor
* Prometheus Agent
* Alertmanager Configuration

### Disaster Recovery

* Velero Backup Schedule

---

# Deployment Workflow


GitHub
   ↓
GitHub Actions
   ↓
Amazon ECR
   ↓
ArgoCD
   ↓
Amazon EKS
   ↓
Argo Rollouts (Canary Deployment)
---
# Deployment Guide
## Terraform

cd terraform
terraform init
terraform plan
terraform apply

## Kubernetes

kubectl apply -f kubernetes/apps/the-redemption

## GitOps

kubectl apply -f kubernetes/gitops/argo-application.yaml
---

# Key Design Decisions

### Why Amazon EKS?

Amazon EKS provides a managed Kubernetes control plane with high availability, scalability, and integration with AWS services.

### Why Aurora PostgreSQL?

Aurora PostgreSQL provides high availability, automated backups, read replicas, and strong transactional consistency.

### Why Redis?

Redis improves application performance through low-latency caching and session storage.

### Why ArgoCD?

ArgoCD enables GitOps-based deployments and ensures Kubernetes clusters remain synchronized with Git repositories.

### Why Argo Rollouts?

Argo Rollouts enables progressive delivery strategies such as canary deployments, reducing deployment risk.

### Why KEDA + HPA + Karpenter?

This combination provides multi-layer autoscaling:

* HPA for pod resource scaling
* KEDA for event-driven scaling
* Karpenter for node provisioning

### Why Velero?

Velero provides Kubernetes-native backup and restore capabilities to support disaster recovery objectives.

---

# Assumptions

* AWS Region: ap-southeast-1
* Single Production Environment
* Existing AWS Account
* Existing Domain Ownership
* Existing CI/CD Platform Access
* Required AWS service quotas are available
* Kubernetes add-ons and CRDs are installed before workload deployment

---

# Documentation
Detailed architecture and design documentation are available at:

docs/The_Redemption_Architecture_Design.pdf

---

# Validation Performed

The following validation activities were completed:

### Terraform


terraform fmt -recursive -check
terraform validate
terraform plan


### Kubernetes

yamllint
kubeconform
kubectl dry-run validation

---

# Author

Myint Hein Kyaw
Cloud Engineer Technical Assessment Submission
