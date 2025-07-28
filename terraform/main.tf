# -------------------------------
# Data sources: Default VPC & Subnet (only ap-south-1a)
# -------------------------------
data "aws_vpc" "default" {
  default = true
}

# Fetch subnet specifically in ap-south-1a
data "aws_subnet" "default" {
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------------
# Existing IAM Role for CodePipeline
# -------------------------------
data "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_access" {
  role       = data.aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_access" {
  role       = data.aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_access" {
  role       = data.aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

# -------------------------------
# Amazon Linux 2 AMI
# -------------------------------
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------------
# Key Pair
# -------------------------------
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("C:/Users/Hp/.ssh/id_ed25519.pub")
}

# -------------------------------
# IAM Role & Profile for EC2
# -------------------------------
resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "ec2-codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "ec2_codedeploy_profile" {
  name = "ec2-codedeploy-profile"
  role = aws_iam_role.ec2_codedeploy_role.name
}

# -------------------------------
# Security Group
# -------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# EC2 Instance for CodeDeploy
# -------------------------------
resource "aws_instance" "codedeploy_instance" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_codedeploy_profile.name

  tags = {
    Name = "CodeDeployInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install ruby -y
              yum install wget -y
              cd /home/ec2-user
              wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF
}

# -------------------------------
# Output: Bucket (assumes already declared elsewhere)
# -------------------------------
output "codepipeline_bucket_name" {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}
