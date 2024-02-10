# S3 bucket
resource "aws_s3_bucket" "meerimprojectbucket2024" {
  bucket = "meerimprojectbucket2024"


}

#s3 access bloc policy
resource "aws_s3_bucket_public_access_block" "block-policy" {
  bucket = aws_s3_bucket.meerimprojectbucket2024.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# s3 bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.meerimprojectbucket2024.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::meerimprojectbucket2024/*"
        ]
      }
    ]
    }
  )
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# s3 Replica
resource "aws_iam_role" "replication" {
  name               = "tf-iam-role-replication-12345"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.meerimprojectbucket2024.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.meerimprojectbucket2024.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.meerimprojectbucket22024.arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "iam-role-policy-replica"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket" "meerimprojectbucket22024" {
  bucket = "meerimprojectbucket22024"
}

resource "aws_s3_bucket_versioning" "v-mproject_bucket2_2024" {
  bucket = aws_s3_bucket.meerimprojectbucket22024.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "source-bucket" {
  #   provider = aws.var.region
  bucket = "meerimprojectbucket2024"
}

resource "aws_s3_bucket_acl" "source_bucket_acl" {
  bucket = aws_s3_bucket.meerimprojectbucket2024.id
  acl    = "private"
}


resource "aws_s3_bucket_versioning" "versioning_mproject_bucket2024" {
  bucket = aws_s3_bucket.meerimprojectbucket2024.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication-config" {
  #   provider = aws.var.region
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning_mproject_bucket2024]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.meerimprojectbucket2024.id

  rule {
    id = "First project"

    filter {
      prefix = "prefix"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.meerimprojectbucket22024.arn
      storage_class = "STANDARD"
    }
  }
}