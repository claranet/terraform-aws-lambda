# Generates a filename for the zip archive based on the contents of the files
# in source_path. The filename will change when the source code changes.
locals {
  default_version   = "v0.0.0"
  published_version = var.published_version == "" ? local.default_version : var.published_version
  rebuild           = var.rebuild == true || random_pet.published_version.id != var.published_version_id
  new_filename      = local.rebuild ? lookup(data.external.archive.result, "filename") : var.published_filename
  old_filename      = local.rebuild ? lookup(null_resource.archive.triggers, "filename") : var.published_filename
}

resource "random_pet" "published_version" {
  keepers = {
    version = local.published_version
  }
}

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
    filename = local.new_filename
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
    filename_old   = local.old_filename
    filename_new   = local.new_filename
    module_relpath = path.module
  }
}
