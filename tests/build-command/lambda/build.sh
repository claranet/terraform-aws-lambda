#!/bin/bash
# 
# Compiles a Python package into a zip deployable on AWS Lambda.
#
# - Builds Python dependencies into the package, using a Docker image to
#   correctly build native extensions
# - Able to be used with the terraform-aws-lambda module
#
# Dependencies:
#
# - Docker
#
# Usage:
#
# $ ./build.sh <output-zip-filename> <runtime> <source-path>

set -euo pipefail

# Read variables from command line arguments
FILENAME=$1
RUNTIME=$2
SOURCE_PATH=$3

# Convert to absolute paths
SOURCE_DIR=$(cd "$SOURCE_PATH" && pwd)
ZIP_DIR=$(cd "$(dirname "$FILENAME")" && pwd)
ZIP_NAME=$(basename "$FILENAME")

# Install dependencies, using a Docker image to correctly build native extensions
docker run --rm -t -v "$SOURCE_DIR:/src" -v "$ZIP_DIR:/out" lambci/lambda:build-$RUNTIME sh -c "
    cp -r /src /build &&
    cd /build &&
    pip install --progress-bar off -r requirements.txt -t . &&
    chmod -R 755 . &&
    zip -r /out/$ZIP_NAME . &&
    chown \$(stat -c '%u:%g' /out) /out/$ZIP_NAME
"

echo "Created $FILENAME from $SOURCE_PATH"
