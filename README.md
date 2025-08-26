# 🛒 E-Commerce Website with ECS and CI/CD Pipeline

In today’s digital landscape, delivering a **scalable, resilient, and automated platform** for your e-commerce business is key to staying competitive.  

This project demonstrates a **complete, enterprise-grade approach** to deploying an e-commerce website on **AWS ECS Fargate** — a serverless container platform — alongside **Application Load Balancer (ALB)**, a custom **VPC**, and **Docker containers** sourced from **Amazon Elastic Container Registry (ECR)**.  

To enable smooth and reliable delivery, we use **AWS CodePipeline** integrated with GitHub. The automated pipeline handles everything from building container images to deploying with **blue/green strategies** for **zero downtime**.  

All infrastructure is provisioned with **Terraform (IaC)** for reproducibility, auditability, and ease of modification.  

---

## 📐 Project Architecture

![Architecture Diagram](docs/architecture.png) <!-- optional if you add a diagram -->

---

## ⚙️ Infrastructure Components

- **VPC** – Isolated network with public and private subnets  
- **ECS Cluster** – Fargate-based container hosting  
- **ALB** – Application Load Balancer for routing traffic  
- **ECR** – Container registry for Docker images  
- **CodePipeline** – Orchestrates the CI/CD workflow  
- **CodeBuild** – Builds Docker images and pushes to ECR  
- **CodeDeploy** – Handles blue/green deployments to ECS  

---

## 🔄 How it Works

1. **Developer Pushes Code to GitHub**  
   A commit to the main branch triggers the pipeline.  

2. **Source Captured by CodePipeline**  
   CodePipeline pulls the latest changes from GitHub.  

3. **Docker Image Build & Push to ECR**  
   CodeBuild builds a Docker image and uploads it to ECR.  

4. **Infrastructure Managed by Terraform**  
   - VPC, ECS, ALB, Security Groups, Auto Scaling, etc.  
   - Ensures consistency across environments.  

5. **Blue/Green Deployment with ECS & ALB**  
   - New tasks deployed (green) alongside old tasks (blue).  
   - Traffic shifts only after health checks pass.  
   - Ensures **zero downtime**.  

6. **Automated Validation & Promotion**  
   - Health checks & smoke tests validate the new deployment.  
   - If successful, traffic fully shifts to green.  

7. **Repeat Continuously**  
   Every push = automatic build, test, deploy.  

---

## ✅ Prerequisites

- AWS Account  
- GitHub repository with your application code  
- Terraform installed locally  
- AWS CLI configured with appropriate credentials  

---

## 🚀 Setup Instructions

### 1. Update GitHub Repository Info
In `infra/terraform.tfvars`:

```hcl
github_repo   = "your-github-username/e-commerce-website-with-ecs"
github_branch = "main"

2. Deploy Infrastructure
cd infra
terraform init
terraform plan
terraform apply --auto-approve

3. Complete GitHub Connection

Go to AWS Console > Developer Tools > Settings > Connections

Find the connection named github-connection

Click Update pending connection

Authenticate with your GitHub account

4. Push Code to Trigger Pipeline
git add .
git commit -m "Initial commit"
git push origin main

🧹 Cleanup

To remove all resources:

cd infra
terraform destroy

📌 Project Info

Project Name: E-Commerce-CICD-with-ECS

Focus: ECS Fargate + Terraform + AWS CodePipeline

Pipeline: GitHub → CodePipeline → CodeBuild → ECR → ECS (Blue/Green)
