# Define la base de datos de Glue donde se almacenará el catálogo
resource "aws_glue_catalog_database" "glue_db" {
  name = "etl-coc-glue-db"
}

# Crea un crawler de Glue para los datos crudos en S3
resource "aws_glue_crawler" "glue_raw_data_crawler" {
  name          = "etl-coc-glue-raw-data-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.glue_db.name
  s3_target {
    path = "s3://${aws_s3_bucket.raw_data.bucket}/raw/"
  }
  depends_on = [
    aws_iam_role_policy_attachment.glue_crawler_role_attach
  ]
}

# Crea un crawler de Glue para los datos procesados por fecha en S3
resource "aws_glue_crawler" "glue_processed_data_date_crawler" {
  name          = "etl-coc-glue-processed-data-date-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.glue_db.name
  s3_target {
    path = "s3://${aws_s3_bucket.processed_data.bucket}/dim/dates/"
  }
  depends_on = [
    aws_iam_role_policy_attachment.glue_crawler_role_attach
  ]
}

# Crea un crawler de Glue para los datos procesados de transacciones en S3
resource "aws_glue_crawler" "glue_processed_data_transactions_crawler" {
  name          = "etl-coc-glue-processed-data-transactions-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.glue_db.name
  s3_target {
    path = "s3://${aws_s3_bucket.processed_data.bucket}/fact/transactions/"
  }
  depends_on = [
    aws_iam_role_policy_attachment.glue_crawler_role_attach
  ]
}
