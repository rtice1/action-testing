provider "aws" {
  region = var.region
}

locals {
  bucket_name  = "evolve-${var.user_name}-${var.application_name}"
  cluster_name = "evolve-${var.user_name}-${var.application_name}"
  subnet_ids   = ["subnet-0d2db32695350ca8b", "subnet-004893ed64e987114"]
  tags = {
    Company     = "Evolve"
    Environment = "Assessment"
    Name        = local.bucket_name
  }
}

# S3
resource "aws_kms_key" "evolve_key" {
  count                   = var.use_kms ? 1 : 0
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  tags                    = local.tags
}

resource "aws_s3_bucket" "evolve_bucket" {
  bucket = local.bucket_name
  tags   = local.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
        kms_master_key_id = var.use_kms ? "your-kms-key-id" : null
      }
    }
  }
}

resource "aws_s3_bucket_policy" "evolve_bucket_policy" {
  count  = 1 # setting this as count, as this would be a conditional expression in a production environment for use cases that do not require a bucket policy, and use the acl parameter (and therefore no need to create this resource)
  bucket = local.bucket_name
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.evolve_bucket.id}/*",
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.evolve_bucket.id}/*",
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "true"
          }
        }
      }
    ]
  }
  EOF
}
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.evolve_bucket.id
  block_public_acls       = var.tls_policy ? false : true
  block_public_policy     = var.tls_policy ? false : true
  ignore_public_acls      = var.tls_policy ? false : true
  restrict_public_buckets = var.tls_policy ? false : true
}

# ECR
resource "aws_ecr_repository" "evolve_ecr" {
  count                = var.create_ecr ? 1 : 0
  name                 = local.bucket_name
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# EKS 
resource "aws_eks_cluster" "example" {
  count    = var.create_eks ? 1 : 0
  name     = "example"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = local.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example[0].name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = local.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "eks-cluster-example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}