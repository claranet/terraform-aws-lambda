#!/usr/bin/env python2
import sys
import json
import boto3

# setup connection to AWS
client = boto3.client('kms')

# get the default KMS key
key_aliases = client.list_aliases()['Aliases']

arn = None

for alias in key_aliases:
    if alias['AliasName'] == 'alias/aws/lambda':
        arn = alias['AliasArn']

if not arn:
    json.dump({
        'default_lambda_kms_key_arn': ""
    }, sys.stdout, indent=2)
    sys.stdout.write('\n')
    sys.stderr.write("Aborting, could not find default KMS key for Lambda: "
                     "alias/aws/lambda\n")
    sys.exit(1)

# Output the result to Terraform.
json.dump({
    'default_lambda_kms_arn': arn
}, sys.stdout, indent=2)
sys.stdout.write('\n')
