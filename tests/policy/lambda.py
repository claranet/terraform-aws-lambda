def lambda_handler(event, context):
    if event['pass']:
        return True
    else:
        raise Exception('oh no')
