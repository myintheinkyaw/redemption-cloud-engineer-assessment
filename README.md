# The Redemption Platform

Cloud Engineer Technical Assessment Submission

Author: Myint Hein Kyaw

---

## Solution Overview

The Redemption Platform is a cloud-native microservice architecture designed to support global hotel loyalty point redemption transactions.

The solution is built on AWS and follows AWS Well-Architected Framework principles with a focus on:

* Reliability
* Scalability
* Security
* Operational Excellence
* Cost Optimization

The platform leverages Amazon EKS, Aurora PostgreSQL, ElastiCache Redis, CloudFront, AWS WAF, GitOps deployment practices, and Infrastructure as Code (Terraform).

---

## Architecture Highlights

* Multi-AZ Deployment (ap-southeast-1)
* Amazon EKS
* Amazon Aurora PostgreSQL
* Amazon ElastiCache Redis
* Amazon CloudFront
* AWS WAF
* AWS Shield Advanced
* GitOps with ArgoCD
* Canary Deployments with Argo Rollouts
* KEDA + HPA + Karpenter Autoscaling
* AWS Managed Prometheus & Grafana
* AWS Backup & Velero

---

## Architecture Diagram

Refer to:

architecture/redemption-architecture.png

---

## Repository Structure

redemption-cloud-engineer-assessment/
├── architecture/
├── docs/
├── kubernetes/
├── terrasorm/
└── .gtignore/

---

## Infrastructure Components

### Terraform

Infrastructure resources are provisioned using Terraform:

* VPC
* Public / Private Subnets
* NAT Gateways
* Application Load Balancer
* Amazon EKS
* Aurora PostgreSQL
* ElastiCache Redis
* CloudFront & WAF
* Monitoring
* Backup Services

### Kubernetes

Kubernetes manifests include:

* Deployment
* Service
* Ingress
* Horizontal Pod Autoscaler
* KEDA ScaledObject
* Argo Rollout
* Network Policies
* Velero Backup Configuration

---

## Deployment Workflow

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

## Documentation

Detailed architecture and design decisions are available in:

docs/The_Redemption_Architecture_Design.pdf

---

## Assumptions

* AWS Region: ap-southeast-1
* Single Production Environment
* Existing AWS Account
* Existing Domain Ownership
* Existing CI/CD Platform Access

---

## Author

Myint Hein Kyaw

Cloud Engineer Technical Assessment
