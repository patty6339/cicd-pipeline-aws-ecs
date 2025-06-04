# E-Commerce Website with ECS and CI/CD Pipeline

This project deploys an e-commerce website on AWS ECS with a complete CI/CD pipeline.

## Architecture

- **Frontend**: Static HTML/CSS/JS website
- **Infrastructure**: AWS ECS Fargate, ALB, VPC, ECR
- **CI/CD**: AWS CodePipeline, CodeBuild, CodeDeploy

## CI/CD Pipeline

The CI/CD pipeline automates the build and deployment process:

1. **Source**: Code is pulled from GitHub when changes are pushed
2. **Build**: Docker image is built and pushed to ECR
3. **Deploy**: New version is deployed to ECS using blue/green deployment

## Prerequisites

- AWS Account
- GitHub repository with your code
- Terraform installed locally
- AWS CLI configured

## Setup Instructions

### 1. Update GitHub Repository Information

Update the GitHub repository variables in `infra/terraform.tfvars`:

```hcl
github_repo  = "your-github-username/e-commerce-website-with-ecs"
github_branch = "main"
```

### 2. Deploy Infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply --auto-approve
```

### 3. Complete GitHub Connection

After deployment, you need to complete the GitHub connection:

1. Go to AWS Console > Developer Tools > Settings > Connections
2. Find the connection named "github-connection"
3. Click "Update pending connection"
4. Follow the prompts to connect to your GitHub account

### 4. Push Code to Trigger Pipeline

Once the connection is established, push code to your repository to trigger the pipeline:

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

## Infrastructure Components

- **VPC**: Isolated network with public and private subnets
- **ECS Cluster**: Fargate-based container hosting
- **ALB**: Load balancer for routing traffic
- **ECR**: Container registry for Docker images
- **CodePipeline**: Orchestrates the CI/CD workflow
- **CodeBuild**: Builds Docker images
- **CodeDeploy**: Deploys to ECS with blue/green strategy

## Cleanup

To remove all resources:

```bash
cd infra
terraform destroy
```# E-Commerce-CICD-with-ECS
