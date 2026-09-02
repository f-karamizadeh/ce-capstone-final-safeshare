import boto3

def handler(event, context):
    cw = boto3.client('cloudwatch')
    cw.put_metric_data(
        Namespace='SafeShare/Business',
        MetricData=[
            {'MetricName': 'DownloadCount', 'Value': 1, 'Unit': 'Count'}
        ]
    )
    return {"status": "logged"}