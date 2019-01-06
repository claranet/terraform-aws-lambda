#!/bin/bash
# 
# Compiles a Python package into a zip deployable on AWS Lambda.
#
# - Builds Python dependencies into the package, using Docker
#   using a Docker image to correctly build native extensions
# - Able to be used with the terraform-aws-lambda module
#
# Dependencies:
#
# - Docker
# - base64
# - jq
#
# Usage:
#
# $ ./build.sh "$(echo { \"filename\": \"out.zip\", \"runtime\": \"python3.7\", \"source_path\": \".\" \} | jq . | base64)"
#
# - Arguments to be provided as JSON, then Base64 encoded

set -euo pipefail

# Extract variables from the JSON-formatted, Base64 encoded input argument.
# This is to conform to arguments as passed in by hash.py
eval "$(echo $1 | base64 --decode | jq -r '@sh "FILENAME=\(.filename) RUNTIME=\(.runtime) SOURCE_PATH=\(.source_path)"')"

# Convert to absolute paths
SOURCE_DIR=$(cd "$SOURCE_PATH" && pwd)
ZIP_DIR=$(cd "$(dirname "$FILENAME")" && pwd)
ZIP_NAME=$(basename "$FILENAME")

# Install dependencies, using a Docker image to correctly build native extensions
docker run --rm -t -v "$SOURCE_DIR:/src" -v "$ZIP_DIR:/out" lambci/lambda:build-$RUNTIME sh -c "
    cp -r /src /build &&
    cd /build &&
    pip install -r requirements.txt -t . &&
    chmod -R 755 . &&
    zip -r /out/$ZIP_NAME * &&
    chown \$(stat -c '%u:%g' /out) /out/$ZIP_NAME
"

echo "Created $FILENAME from $SOURCE_PATH"
