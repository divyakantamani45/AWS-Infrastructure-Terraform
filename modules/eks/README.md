# 🚀 EKS Module

This Terraform module provisions an **Amazon Elastic Kubernetes Service (EKS)** cluster inside a given VPC, along with required IAM roles, security groups, and node groups.  
It is designed to be **plug-and-play** inside a larger Terraform project but can also be used independently.

---

## 📌 Features
- Creates an **EKS cluster** with control plane in private subnets  
- Manages **IAM roles** for EKS and worker nodes  
- Provisions **Node Groups** (scalable EC2-based worker nodes)  
- Adds **Security Groups** for EKS communication  
- Supports **kubectl configuration** export for local access  

---

## ⚡ Usage

```hcl
module "eks" {
  source          = "./eks"
  cluster_name    = "my-eks-cluster"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  desired_size    = 2
  min_size        = 1
  max_size        = 4
}
```

---

## 🔑 Inputs

| Name              | Type   | Default | Description                                     |
|-------------------|--------|---------|-------------------------------------------------|
| `cluster_name`    | string | n/a     | Name of the EKS cluster (required)             |
| `vpc_id`          | string | n/a     | The VPC where EKS will be deployed             |
| `private_subnets` | list   | n/a     | List of private subnet IDs for worker nodes    |
| `public_subnets`  | list   | n/a     | List of public subnet IDs (used for ALB, etc.) |
| `desired_size`    | number | `2`     | Desired number of worker nodes                 |
| `min_size`        | number | `1`     | Minimum number of worker nodes                 |
| `max_size`        | number | `3`     | Maximum number of worker nodes                 |

---

## 📤 Outputs

| Name              | Description                                |
|-------------------|--------------------------------------------|
| `cluster_id`      | The ID of the EKS cluster                  |
| `cluster_name`    | The name of the EKS cluster                |
| `cluster_endpoint`| Endpoint for Kubernetes API server         |
| `cluster_ca`      | CA certificate for the cluster             |
| `node_group_arn`  | ARN of the created node group              |

---

## 🛠️ Deployment

```bash
terraform init
terraform apply -var-file=dev.tfvars
```

After creation, update your **kubeconfig** to interact with the cluster:

```bash
aws eks --region <region> update-kubeconfig --name my-eks-cluster
kubectl get nodes
```

---

## 📸 Verification

Run the following to verify:

```bash
kubectl get svc
kubectl get pods -A
```

You should see the default `kube-system` pods and services running.

---

## 🧹 Cleanup

To destroy only the EKS resources (not the entire infra):

```bash
terraform destroy -target=module.eks
```

---

## 🔒 Security Highlights
- Private subnets for worker nodes (no public exposure)  
- Least privilege IAM roles for EKS control plane and nodes  
- Security groups scoped to required Kubernetes ports  

---

## 📌 Notes
- Ensure your VPC and subnets are provisioned before using this module.  
- You need AWS CLI configured with sufficient permissions.  
- This module assumes you’re deploying inside a **regional VPC** (not default VPC).  

---

👨‍💻 **Author:** Divya 
📧 Contact: divyakantamani1306@gmail.com  
