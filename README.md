# Scalable, Containerized Web Application with Full CI/CD and Monitoring

This repository contains the complete solution for deploying a scalable, containerized web application on AWS. The project includes a Node.js backend and a React (placeholder) frontend, provisioned with Terraform, and deployed automatically via a GitHub Actions CI/CD pipeline.

## Table of Contents

- [Infrastructure Design & Diagram](#infrastructure-design--diagram)
- [Deployment Instructions](#deployment-instructions)
- [CI/CD Pipeline Steps](#cicd-pipeline-steps)
- [Monitoring and Alerting](#monitoring-and-alerting)
- [Accessing the Application](#accessing-the-application)
- [Final Deliverables](#final-deliverables)

## Infrastructure Design & Diagram

The infrastructure is designed for scalability, security, and maintainability, using modern cloud-native practices. All resources are defined as code using Terraform in the `/infrastructure` directory.

### Core Components

-   **Networking**: A custom VPC with public and private subnets across two availability zones for high availability. An Internet Gateway provides public access, and a NAT Gateway allows private resources to access the internet for tasks like pulling container images.
-   **Compute**: Amazon ECS on AWS Fargate is used for container orchestration. This serverless approach eliminates the need to manage EC2 instances, simplifying operations. We have separate ECS services for the frontend and backend.
-   **Load Balancing**: An Application Load Balancer (ALB) serves as the single entry point for all traffic. It is configured to listen on HTTPS, terminate SSL, and route traffic to the appropriate backend or frontend service based on the URL path (`/api/*` for the backend, everything else for the frontend).
-   **Container Registry**: Amazon ECR (Elastic Container Registry) stores the Docker images for the frontend and backend applications. Images are scanned for vulnerabilities on push.
-   **Security**:
    -   Network security is enforced via AWS Security Groups, which act as virtual firewalls. The ECS tasks are in private subnets and only accept traffic from the ALB.
    -   The application is protected from public access using Amazon Cognito for authentication, which is integrated directly with the ALB.
    -   All traffic is encrypted in transit via HTTPS, with an SSL certificate managed by AWS Certificate Manager (ACM).
-   **Observability**: Application health is monitored using Amazon CloudWatch. Metrics like CPU utilization are tracked for the ECS services, and an alarm is configured to send notifications via an SNS topic if thresholds are breached.

### Infrastructure Diagram

The following diagram illustrates the architecture. You can find the source code for this diagram in `/docs/infrastructure_diagram.md`.

![Infrastructure Diagram](docs/infrastructure_diagram.md)

## Deployment Instructions

To deploy this entire solution from scratch, follow these steps.

### Prerequisites

1.  **AWS Account**: An AWS account with the necessary permissions to create the resources defined in the Terraform code.
2.  **AWS CLI**: The AWS CLI installed and configured on your local machine with credentials.
3.  **Terraform**: Terraform CLI (version 1.0 or later) installed on your local machine.
4.  **Registered Domain**: A domain name registered in Amazon Route 53.
5.  **GitHub Repository**: A GitHub repository forked from this one.

### Step 1: Deploy the Infrastructure with Terraform

1.  Navigate to the `infrastructure` directory:
    ```bash
    cd infrastructure
    ```

2.  Create a `terraform.tfvars` file to provide values for the variables. At a minimum, you must provide the `domain_name` and `cognito_user_password`.
    ```terraform
    # example terraform.tfvars
    domain_name           = "your-domain.com"
    cognito_user_password = "YourSecurePassword123!"
    ```

3.  Initialize Terraform:
    ```bash
    terraform init
    ```

4.  Apply the Terraform configuration. This will provision all the AWS resources.
    ```bash
    terraform apply
    ```
    Terraform will show you a plan and ask for confirmation. Type `yes` to proceed.

5.  After the apply is complete, Terraform will output several important values. You will need these for the next step.

### Step 2: Configure Secrets in GitHub

The CI/CD pipeline requires several secrets to be configured in your GitHub repository settings under `Settings > Secrets and variables > Actions`. Use the output values from the `terraform apply` command to populate these.

**Required Secrets:**
-   `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
-   `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
-   `ECR_REPOSITORY_BACKEND`: The full URI of the backend ECR repository.
-   `ECR_REPOSITORY_FRONTEND`: The full URI of the frontend ECR repository.
-   `ECS_CLUSTER`: The name of the ECS cluster (e.g., `internal-dashboard-cluster`).
-   `ECS_SERVICE_BACKEND`: The name of the backend ECS service (e.g., `internal-dashboard-backend-service`).
-   `ECS_SERVICE_FRONTEND`: The name of the frontend ECS service (e.g., `internal-dashboard-frontend-service`).
-   `ECS_TASK_DEFINITION_NAME_BACKEND`: The name of the backend task definition (e.g., `internal-dashboard-backend-task`).
-   `ECS_TASK_DEFINITION_NAME_FRONTEND`: The name of the frontend task definition (e.g., `internal-dashboard-frontend-task`).

### Step 3: Trigger the CI/CD Pipeline

Once the infrastructure is up and the secrets are configured, the pipeline will run automatically on the next push to the `main` branch. To trigger it manually for the first time:

1.  Make a small change to the code (e.g., add a comment to this README).
2.  Commit and push the change to the `main` branch.
    ```bash
    git add .
    git commit -m "Trigger initial deployment"
    git push origin main
    ```

You can monitor the pipeline's progress in the "Actions" tab of your GitHub repository.

## CI/CD Pipeline Steps

The CI/CD pipeline is defined in `.github/workflows/deploy.yml`. It automates the process of building and deploying the application.

The pipeline consists of a single job, `deploy`, which performs the following steps:

1.  **Checkout Code**: The job checks out the source code from the repository.
2.  **Configure AWS Credentials**: It authenticates with AWS using the secrets provided.
3.  **Login to Amazon ECR**: It logs the Docker client into the Amazon ECR registry.
4.  **Build, Tag, and Push Backend Image**: It builds the Docker image for the backend service, tags it with the unique Git SHA, and pushes it to the backend ECR repository.
5.  **Deploy Backend Service**: It downloads the latest active ECS task definition for the backend, updates it with the new image URI, and deploys the new task definition to the ECS service. It waits for the deployment to become stable.
6.  **Build, Tag, and Push Frontend Image**: It repeats the build and push process for the frontend service.
7.  **Deploy Frontend Service**: It repeats the deployment process for the frontend service.

## Monitoring and Alerting

The application's health is monitored using Amazon CloudWatch.

-   **Metrics**: The primary metric being monitored is `CPUUtilization` for the backend ECS service.
-   **Alarm**: A CloudWatch Alarm named `internal-dashboard-backend-cpu-utilization-high` is configured to trigger if the average CPU utilization is greater than or equal to 70% for a sustained period of 10 minutes.
-   **Notifications**: When the alarm state changes, it sends a notification to an SNS topic. To receive these notifications, you must subscribe an endpoint (like an email address) to the SNS topic `internal-dashboard-alarms-topic`. An example for an email subscription is commented out in `infrastructure/cloudwatch.tf`.

## Accessing the Application

1.  **DNS Configuration**: After `terraform apply` completes, take the `alb_dns_name` output value and create a CNAME record in your DNS provider that points your domain (e.g., `dashboard.your-domain.com`) to this ALB DNS name.
2.  **Authentication**: Navigate to your domain in a browser. You will be redirected to the Cognito login page.
3.  **Login Credentials**:
    -   **Username**: `admin` (or the value of `cognito_user_username` if you changed it).
    -   **Password**: The password you provided in `terraform.tfvars`.
4.  **View Application**: After successful login, you will be redirected to the application and should see the "Hello from the Frontend!" message.

## Final Deliverables

This repository is structured to meet all the project requirements.

-   `/infrastructure`: Contains all Terraform (`.tf`) files for provisioning the AWS infrastructure.
-   `/cicd`: Contains documentation related to the CI/CD pipeline. The live pipeline is in `/.github/workflows/deploy.yml`.
-   `/docs`: Contains the infrastructure diagram and screenshot placeholders.
-   `/backend` & `/frontend`: Contain the placeholder application code and their `Dockerfiles`.
-   `README.md`: This file.

---
*This project was completed by Jules, an AI software engineer.*
