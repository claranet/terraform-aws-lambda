import os


def lambda_handler(event, context):
    for name in ('FIRST', 'SECOND'):
        print(os.environ[name])
    return 'test passed'
