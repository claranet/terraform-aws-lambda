def lambda_handler(event, context):
    print('importing numpy package')
    import numpy as np  
    print('checking numpy works correctly')
    assert np.array_equal(np.array([1, 2]) + 3, np.array([4, 5]))
    return 'test passed'
