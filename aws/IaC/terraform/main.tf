##################################################################################
# Create Keys in the Secrets Manager
# These keys will be used by the tool to authenticate and output exports with the load tool
module "asm" {
  source  = "./modules/secrets-manager"
  project = var.project
  env     = var.env
  secret_value = [
    {
      key   = "OUTPUT"
      value = "--out influxdb=http://grafana.dev.k6testload.in:8086/k6"
    },
    {
      key   = "TOKEN"
      value = "###"
    }
    , {
      key   = "ANOTHER_TOKEN"
      value = "###"
    }
  ]
}

##################################################################################
# Crate S3 Bucket to store Codebuild artifacts
# This bucket will be used by the tool to store the codebuild artifacts
module "s3" {
  source               = "./modules/s3"
  project              = var.project
  env                  = var.env
  bucket_artifact_name = "codepipeline-artifact-store"
}

##################################################################################
# Create Security groups to be used by the tool
# These security groups will be used by the tool to communicate with the resources ELB, Instances, Codebuild
module "sgs" {
  source  = "./modules/security-groups"
  project = var.project
  env     = var.env
  vpc_id  = var.vpc_id
  sg_ingress = {

    # SG for codebuild be to comunicate inside VPC resources
    codebuild-sg = {
      description = "Security to codebuild instances"
      name        = "codebuild-sg"
      ingress = [
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = [var.vpc_cdir_block]
          description = "Allow internal traffic HTTPS to VPC"
        }
      ]
    }

    # Create grafana instance security group
    # Ingress rules are allowing only:
    #   - port 3000 from ELB
    #   - port 22 from bastion host
    #   - port 8086 from CIDR 
    grafana-instance-sg = {
      description = "Security group to Grafana and Influxdb instance"
      name        = "grafana-instance-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow ssh connect from bastion"
        },
        {
          from_port       = 8086,
          to_port         = 8086,
          protocol        = "tcp",
          cidr_blocks     = [var.vpc_cdir_block]
          security_groups = []
          description     = "Allow ingress to InfluxDB through VPC"
        },
        {
          from_port       = 3000,
          to_port         = 3000,
          protocol        = "tcp",
          cidr_blocks     = []
          security_groups = []
          description     = "Allow Grafana ingress from Load Balancer"
        }
      ]
    }

    # SG for bastion instance
    # Ingress rules are allowing only:
    #   - port 22 from external private IP
    bastion-sg = {
      description = "Security group to bastion access"
      name        = "bastion-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = ["${var.my_external_ip}/32"]
          description = "Allow ssh to private ip to internet"
        }
      ]
    }

    # SG for ELB Grafana instance
    elb-sg = {
      description = "Security group for ELB Grafana instance"
      name        = "grafana-elb-sg"
      ingress = [
        {
          from_port       = 80,
          to_port         = 80,
          protocol        = "tcp",
          cidr_blocks     = ["${var.my_external_ip}/32"]
          security_groups = []
          description     = "Allow restrict http access to the ELB"
        },
        {
          from_port       = 443,
          to_port         = 443,
          protocol        = "tcp",
          cidr_blocks     = ["${var.my_external_ip}/32"]
          security_groups = []
          description     = "Allow restrict https access to the ELB"
        }
      ]
    }
  }

}

##################################################################################
# Create EC2 Web Grafana and Bastion instances to be used by the tool
# These instances will be used by the tool to run the load test
module "ec2-instance" {
  source  = "./modules/ec2-instance"
  project = var.project
  env     = var.env
  instance_settings = [
    # Grafana Web Instance to show the results of the load test
    # The user data script will be executed after the instance is created
    # This script will be used to install docker, docker compose and execute the grafana container and setup InflixDB conector and import dashboard
    {
      instance_name   = "grafana-web"
      instance_type   = "t2.micro"
      ami             = "ami-0866a3c8686eaeeba"    # Ubuntu 22.04 image 
      subnet          = var.private_subnet_ids[0]  # Set some private subnet 
      security_groups = [module.sgs.id.grafana_sg] # Security Group with ingress rules for the Grafana
      user_data       = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt upgrade -y 
                sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

                #Setting Docker and Docker Compose
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
                sudo apt update
                sudo apt install docker-ce docker-compose -y

                # Clone repository
                cd /home/ubuntu
                git clone https://github.com/davidlimacardoso/k6-multi-load-tests.git
                cd k6-multi-load-tests/docker/grafana

                # Execute containers
                sudo docker compose up -d

                #Set containers to start automatically
                sudo docker update --restart always grafana-influxdb-1
                sudo docker update --restart always grafana-grafana-1
                
                # Configure Influxdb conection and dashboard to grafana
                sleep 30
                sudo chmod +x dashboard.sh 
                sudo ./dashboard.sh
              EOF
    },

    # EC2 instance to be used as a Bastion host to connect to Grafana and InfluxDB
    {
      is_bastion                  = true
      instance_name               = "grafana-bastion"
      instance_type               = "t2.micro"
      ami                         = "ami-0ebfd941bbafe70c6"  # Amazon Linux 2 AMI (HVM)
      subnet                      = var.public_subnet_ids[0] # Set some public subnet to gives some Public IP
      security_groups             = [module.sgs.id.bastion_sg]
      associate_public_ip_address = true
    }
  ]
}

##################################################################################
# Create internal hosted domain name to be used as OUTPUT throught of the K6 by Secrets Manager
module "route53" {
  source  = "./modules/route53"
  project = var.project
  env     = var.env

  private = {
    name   = "k6testload.in"
    vpc_id = var.vpc_id
    records = [
      {
        name    = "grafana.dev"
        type    = "A"
        ttl     = 300
        records = [module.ec2-instance.ec2_instance.grafana-web.private_ip]
      }
    ]
  }
}

##################################################################################
# Create Codepipeline and Codebuild to be used by the tool to run the load test
module "codepipeline" {
  source             = "./modules/codepipeline"
  project            = var.project
  env                = var.env
  name               = "test-loads"
  vpc_id             = var.vpc_id
  private_subnets    = var.private_subnet_ids
  sg_ids             = [module.sgs.id.codebuild_sg]
  s3_artifact_bucket = module.s3.name.artifact_store
  secrets_manager    = module.asm.secret
  git_repository     = "davidlimacardoso/k6-multi-load-tests" # Git repository of K6 to load tests
  git_branch         = "main"                                 # Set the branch that use to run K6 tests
  container_image    = "davidlimacd/k6-node-alpine:1.0"       # Image to run the Codebuild, this image has installed K6, Node, NPM, Git # You can to use the ECR repository too with the same stack
  git_connection     = "67cd96b0-5760-482c-913a-47a852460bc1" # Before, is necessary to create the Github Connection in CodePipeline > Settings > Developer Tools > Connections
  buildspec          = "aws/buildspec/dev-buildspec.yml"      # Buildspec with properties to be used by the Codebuild
  compute_type       = "BUILD_GENERAL1_SMALL"                 # Set memory and vCPUs, ref: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
}

##################################################################################
# Create Load Balancer to be used by the tool to show the results of the load test
# Use the domain name to show Grafana dashboard
module "elb" {
  source            = "./modules/load-balancer"
  project           = var.project
  env               = var.env
  vpc_id            = var.vpc_id
  name              = "grafana"
  health_path       = "/api/health"
  instance_id       = module.ec2-instance.ec2_instance.grafana-web.id
  lb_security_group = [module.sgs.id.elb_sg]
  subnets           = var.public_subnet_ids
}
