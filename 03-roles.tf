# Define el rol de IAM para Glue
resource "aws_iam_role" "glue_crawler_role" {
  name = "etl-coc-glue-crawler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Adjunta la política de servicio de Glue al rol
resource "aws_iam_role_policy_attachment" "glue_crawler_role_attach" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Define el rol de IAM para Redshift Spectrum
resource "aws_iam_role" "redshift_role" {
  name = "etl-coc-redshift-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Define la política personalizada para Redshift Spectrum
resource "aws_iam_policy" "spectrum_policy" {
  name        = "etl-coc-spectrum-policy"
  description = "Policy to allow Redshift Spectrum and Glue access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::etl-coc-processed-data",
          "arn:aws:s3:::etl-coc-processed-data/*"
        ]
      },
      {
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetTableVersion",
          "glue:GetTableVersions",
          "glue:CreateDatabase",
          "glue:CreateTable",
          "glue:GetPartitions"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "redshift:GetClusterCredentials",
          "sts:AssumeRole",
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Adjunta la política personalizada de Spectrum al rol de Redshift
resource "aws_iam_role_policy_attachment" "spectrum_policy_attachment" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = aws_iam_policy.spectrum_policy.arn
}
