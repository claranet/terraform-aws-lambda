def lambda_handler(event, context):
    print('importing a package from requirements.txt')
    import timeprint
    with timeprint('importing a relative package included in source_dir'):
        import test_result
    return test_result.value
