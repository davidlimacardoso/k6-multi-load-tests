# K6 Load Testing Infrastructure on AWS

## Project Overview

This Terraform project sets up the infrastructure for running K6 load tests on AWS. It includes components such as EC2 instances, security groups, S3 buckets, CodePipeline, CodeBuild, and AWS Secrets Manager.

The differential you can makes multiples instances `K6NodeX` and shared your scripts between nodes with batch, ex:

The package json, you can concatenate his scripts in nodes (`npm run script1 & npm run script2` etc...)
```json
"scripts": {

        "k6Node1": "npm run fakeUserLogin & npm run fakeProductToCart",
        "k6Node2": "npm run fakeAddNewUser",
        "k6Node3": "npm run JsonplaceholderGetPost & npm run JsonplaceholderDelPost",
        "k6Node4": "npm run JsonplaceholderSimulatePost",
.........................................................
        "fakeProductToCart": "ENV=$npm_config_env ... $OUTPUT",
        "fakeAddNewUser": "ENV=$npm_config_env ... $OUTPUT",
        "fakeUserLogin": "ENV=$npm_config_env ... $OUTPUT",
        "JsonplaceholderGetPost": "ENV=$npm_config_env ... $OUTPUT",
        "JsonplaceholderDelPost": "ENV=$npm_config_env ... $OUTPUT",
        "JsonplaceholderSimulatePost": "ENV=$npm_config_env ... $OUTPUT"
        ...
    },
...

```

In the buildspec.yml the numbers of identifiers, will be a number of computers that Codebuild will run.
```yml
...
batch:
  fast-fail: false
  build-list:
    - identifier: k6Node1
      env:
        variables:
          TYPE: k6Node1
      ignore-failure: true
        
    - identifier: k6Node2
      env:
        variables:
          TYPE: k6Node2
      ignore-failure: true

    - identifier: k6Node3
      env:
        variables:
          TYPE: k6Node3
      ignore-failure: true

    - identifier: k6Node4
      env:
        variables:
          TYPE: k6Node4
      ignore-failure: true
          

phases:
  build:
    commands:
    - echo $TYPE
    - npm run $TYPE --env=prd --strategy=ramp
```


## Infrastructure Components

- EC2 Instances:
  - Instace with docker that runs Grafana and InfluxDB
  - Bastion Host
- Security Groups
- S3 Bucket for CodePipeline artifacts
- CodePipeline and CodeBuild for running load tests
- AWS Secrets Manager for storing sensitive information
- Route53 for internal DNS management
- Elastic Load Balancer to show Grafana dashboard

## Prerequisites

- AWS CLI installed and configured
- Terraform v0.12+ installed
- Access to an AWS account with necessary permissions

## Project Structure

```
.
└── terraform
    ├── dev.tfvars
    ├── main.tf
    ├── output.tf
    ├── provider.tf
    ├── vars.tf
    ├── modules/
    │   ├── codepipeline/
    │   ├── ec2-instance/
    │   ├── load-balancer/
    │   ├── route53/
    │   ├── s3/
    │   ├── secrets-manager/
    └   └── security-groups/
```
## Usage

1. Clone the repository:
```bash
git clone <repository-url>
cd <project-directory>
```
2. Modify the variables in `dev.tfvars` file (you may to create stg or prd vars). Set the following variables:
Key variables include:

- `project`: The name of your project, is seted **k6-test-loads**
- `env`: The environment (e.g., dev, staging, prod)
- `region`: AWS region to deploy resources
- `vpc_id`: ID of the VPC to use
- `vpc_cidr_block`: CIDR block of the VPC
- `private_subnet_ids`: List of private subnet IDs
- `public_subnet_ids`: List of public subnet IDs
- `my_external_ip`: Your external IP for security group rules


3. Setup the backend in the providers.tf ou comment it, if you dont use. If you to use, is necessary to create a bucket s3 before:

```bash
aws s3api create-bucket --bucket devops-tests-core --region us-east-1
```

4. Initialize Terraform:
```bash
terraform init
```

5. Plan the infrastructure:
```bash
terraform plan
```
6. Apply the configuration:

```bash
terraform apply
```
# Outputs

The project outputs include:

- S3 bucket names
- Security group IDs
- EC2 instance details
- Route53 zone details
- Load balancer DNS name

Refer to `outputs.tf` for the complete list of outputs.

## Notes

- Ensure that you have the necessary AWS permissions to create and manage the resources defined in this Terraform configuration.
- The Grafana instance is set up with Docker and Docker Compose, pulling configurations from a GitHub repository.
- CodePipeline is configured to use a specific GitHub repository for K6 load tests. Ensure you have the correct repository and branch set up.
- Review and adjust security group rules as needed for your specific requirements.

## Contributing

[Include information about how to contribute to the project, if applicable]

## Licence

[MIT](https://github.com/davidlimacardoso/k6-multi-load-tests/blob/main/LICENSE)