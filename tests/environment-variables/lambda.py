import os


def lambda_handler(event, context):
    print(os.environ['ARN'])
    return 'test passed'
