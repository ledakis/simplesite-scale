# Simple site in AWS with scaling


_Assumption 1: This is to immitate a service running on Docker containers (serving a simple static site for now). The point to be made is that one can modify the dockerfile contents and create a bigger application (not including state per current design)._

_Assumption 2: This was made in a personal AWS account. This means a few resources need to be created before the work even begins for the creation of the service infrastructure. There are two terraform directories one for the general infrastructure and one for the service itself._

_Assumption 3: This will run from a personal machine, with the potential to be changed to work in a pipeline. As a result, the AWS credentials this runs from should have permissions to create the following resources in the plan._

_Assumption 4: An S3 bucket for the states already exists._

Plan

1. Create actual peripheral infrastructure for this.
    * VPC + subnets + rest of networking.
    * S3 bucket for terraform state file.
    * ECR repos.
    * Route 53 zone.
    * Certificate.
2. Docker container
    * Docker file will run nginx.
    * It will serve a simple site that is built inside the container on port 80.
    * Built container to be uploaded on ECR created on step 1.
3. For delivery of that docker container ECS Fargate will be used.
    * Create cluster.
    * Create task definition.
    * Create service.
    * Create IAM roles that are necessary.
    * Scaling policy based on the ALB connections count per target.
4. For the setup of ECS infrastructure as well as the rest of the AWS resources, terraform will be used.
    * Create SGs, ALB, Health checks.
5. Security.
    * Lock down the application with SGs.
    * IAM permissions to include the minimum required.
    * Disabled Public IP for the service tasks.
    * Separate public/private subnets for the ALB/Service respectively.

## Requirements

1. terraform 0.12
2. AWS credentials configured.

## Infra deployment

1. Fill the variable files in `infra_backend.tfvars` and `infra_vars.tfvars` based on the example files.
2. Run `rm -rf .terraform && terraform init -backend-config=infra_backend.tfvars terraform/infrastructure/`
3. Run `terraform apply -target aws_route53_zone.main -var-file=infra_vars.tfvars terraform/infrastructure/` after init as well.
4. Run `terraform apply -var-file=infra_vars.tfvars terraform/infrastructure/` to cover the rest of the resources. The output will provide the url for the ECR repository the image is to be stored.


## Service deployment

1. To build the docker container and upload it to the newly-created ECR repo run: `./build-container.sh <ACCOUNT>.dkr.ecr.eu-west-1.amazonaws.com/<ECR_REPO>`
2. Fill the variable files in `service_backend.tfvars` and `service_vars.tfvars` based on the example files.
3. Run `rm -rf .terraform && terraform init -backend-config=service_backend.tfvars terraform/service/`
4. Run `terraform apply -var-file=service_vars.tfvars terraform/service/`
5. Based on the variables given, the output should display the url of the site.


## Destroy

1. Run `rm -rf .terraform && terraform init -backend-config=service_backend.tfvars terraform/service/`
2. Run `terraform destroy -var-file=service_vars.tfvars terraform/service`
3. Run `rm -rf .terraform && terraform init -backend-config=infra_backend.tfvars terraform/infrastructure/`
4. Run `terraform destroy -var-file=infra_vars.tfvars terraform/infrastructure`
