# Generates a filename for the zip archive based on the contents of the files
# in source_path. The filename will change when the source code changes.
data "external" "archive" {
  program = ["${path.module}/hash.py"]

  query = {
    runtime      = "${var.runtime}"
    source_path  = "${var.source_path}"
    build_script = "${coalesce(var.build_script, "${path.module}/build.py")}"
  }
}

# Build the zip archive whenever the filename changes.
resource "null_resource" "archive" {
  triggers {
    filename = "${lookup(data.external.archive.result, "filename")}"
  }

  provisioner "local-exec" {
    command = "${lookup(data.external.archive.result, "build_command")}"
  }
}

# Check that the null_resource.archive file has been built. This will rebuild
# it if missing. This is used to catch situations where the Terraform state
# does not match the Lambda function in AWS, e.g. after someone manually
# deletes the Lambda function. If the file is rebuilt here, the build
# output is unfortunately invisible.
data "external" "built" {
  program = ["${path.module}/built.py"]

  query = {
    build_command = "${lookup(data.external.archive.result, "build_command")}"
    filename_old  = "${lookup(null_resource.archive.triggers, "filename")}"
    filename_new  = "${lookup(data.external.archive.result, "filename")}"
  }
}
