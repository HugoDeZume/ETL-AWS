

# Define el bucket de S3 para datos crudos
resource "aws_s3_bucket" "raw_data" {
  bucket = "coc-etl-raw-data"
}

# Define el bucket de S3 para datos procesados
resource "aws_s3_bucket" "processed_data" {
  bucket = "coc-etl-processed-data"
}

# Subir datos crudos al bucket de datos crudos
resource "aws_s3_bucket_object" "raw_data_json" {
  bucket = aws_s3_bucket.raw_data.bucket
  key    = "raw/clash_of_clans_data.json"
  source = var.json_route
  acl    = "private"
}

# Subir el script ETL al bucket de datos crudos
resource "aws_s3_bucket_object" "glue_etl_script" {
  bucket = aws_s3_bucket.raw_data.bucket
  key    = "scripts/clash_of_clans_etl_script.py"
  source = var.scripts_route
  acl    = "private"
}

# Configuración de propiedad y acceso público para los buckets de S3
resource "aws_s3_bucket_ownership_controls" "raw_data_ownership" {
  bucket = aws_s3_bucket.raw_data.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_ownership_controls" "processed_data_ownership" {
  bucket = aws_s3_bucket.processed_data.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "raw_data_block" {
  bucket                  = aws_s3_bucket.raw_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "processed_data_block" {
  bucket                  = aws_s3_bucket.processed_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "raw_data_versioning" {
  bucket = aws_s3_bucket.raw_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "processed_data_versioning" {
  bucket = aws_s3_bucket.processed_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "raw_data_acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.raw_data_block,
    aws_s3_bucket_ownership_controls.raw_data_ownership,
  ]

  bucket = aws_s3_bucket.raw_data.id
  acl    = "private"
}

resource "aws_s3_bucket_acl" "processed_data_acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.processed_data_block,
    aws_s3_bucket_ownership_controls.processed_data_ownership,
  ]

  bucket = aws_s3_bucket.processed_data.id
  acl    = "private"
}


