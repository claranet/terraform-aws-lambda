# Generates a filename for the zip archive based on the contents of the files
# in source_path. The filename will change when the source code changes.
data "external" "archive" {
  program = ["python3", "${path.module}/hash.py"]

  query = {
    build_command  = var.build_command
    build_paths    = jsonencode(var.build_paths)
    module_relpath = path.module
    runtime        = var.runtime
    source_path    = var.source_path
  }
}

# Build the zip archive whenever the filename changes.
resource "null_resource" "archive" {
  triggers = {
    filename = lookup(data.external.archive.result, "filename")
  }

  provisioner "local-exec" {
    command     = lookup(data.external.archive.result, "build_command")
    working_dir = path.module
  }
}

# Check that the null_resource.archive file has been built. This will rebuild
# it if missing. This is used to catch situations where the Terraform state
# does not match the Lambda function in AWS, e.g. after someone manually
# deletes the Lambda function. If the file is rebuilt here, the build
# output is unfortunately invisible.
data "external" "built" {
  program = ["python3", "${path.module}/built.py"]

  query = {
    build_command  = lookup(data.external.archive.result, "build_command")
    filename_old   = lookup(null_resource.archive.triggers, "filename")
    filename_new   = lookup(data.external.archive.result, "filename")
    module_relpath = path.module
  }
}

resource "aws_s3_bucket_object" "lambda_package" {
  count      = var.s3_bucket_lambda_package != null ? 1 : 0
  bucket     = aws_s3_bucket.lambda_package[0].id
  depends_on = [aws_s3_bucket.lambda_package]
  key        = lookup(data.external.archive.result, "filename")
  source     = data.external.built.result.filename
  etag       = filemd5(data.external.built.result.filename)
}
