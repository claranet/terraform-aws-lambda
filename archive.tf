# Generates a filename for the zip archive based on the contents of source_dir
# and source_file. The filename will change when the source code changes.
data "external" "archive" {
  program = ["python", "${path.module}/hash.py"]

  query = {
    runtime     = "${var.runtime}"
    source_path = "${var.source_path}"
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
