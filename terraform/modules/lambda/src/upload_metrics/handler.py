import boto3
def handler(event, context):
    cw = boto3.client('cloudwatch')
    size = event['detail']['object']['size']
    cw.put_metric_data(
        Namespace='SafeShare/Business',
        MetricData=[
            {'MetricName': 'UploadCount', 'Value': 1, 'Unit': 'Count'},
            {'MetricName': 'FileSize', 'Value': size, 'Unit': 'Bytes'}
        ]
    )
    return {"status": "ok"}