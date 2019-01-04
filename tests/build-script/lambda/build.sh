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
# $ ./build.sh
#
# - Defaults are to build the current path to out.zip
#
# $ ./build.sh "$(echo { \"filename\": \"out.zip\", \"runtime\": \"python3.7\", \"source_path\": \".\" \} | jq . | base64)"
#
# - Arguments to be provided as JSON, then Base64 encoded

set -e

# Extract variables from the JSON-formatted, Base64 encoded input argument.
# This is to conform to arguments as passed in by hash.py
eval "$(echo $1 | base64 -D | jq -r '@sh "FILENAME=\(.filename) RUNTIME=\(.runtime) SOURCE_PATH=\(.source_path)"')"

# Apply default values for missing arguments
FILENAME="${FILENAME:-out.zip}"
RUNTIME="${RUNTIME:-python3.7}"
SOURCE_PATH="${SOURCE_PATH:-.}"

# Convert to absolute paths
FILEPATH="$(cd "$(dirname "$FILENAME")"; pwd)/$(basename "$FILENAME")"
SOURCE_PATH="$(cd "$SOURCE_PATH"; pwd)"

# Setup a temporary path for the build
TEMP_BUILD_PATH=$(mktemp -d "/tmp/build-lambda.XXXXXXXXX")
trap "{ rm -rf '$TEMP_BUILD_PATH'; }" EXIT

# Copy source code
cp "$SOURCE_PATH"/*.py "$SOURCE_PATH/requirements.txt" "$TEMP_BUILD_PATH"/

# Install dependencies, using a Docker image to correctly build native extensions
docker run --rm -t -v "$TEMP_BUILD_PATH:/code" -w /code lambci/lambda:build-$RUNTIME \
    sh -c "pip install -r requirements.txt -t ."

# Required by AWS Lambda
chmod -R 755 "$TEMP_BUILD_PATH"

# Cleanup old build output
[ -f "$FILEPATH" ] && rm "$FILEPATH"

# Build zip package with files at root
(cd "$TEMP_BUILD_PATH"; zip -r $FILEPATH *)

echo "Created $FILEPATH from $SOURCE_PATH"
