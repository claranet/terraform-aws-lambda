import subprocess


def lambda_handler(event, context):

    subprocess.run(['git'])

    return 'test passed'
