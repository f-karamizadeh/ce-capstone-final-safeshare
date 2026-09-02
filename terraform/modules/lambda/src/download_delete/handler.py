import boto3

def handler(event, context):
    s3 = boto3.client('s3')
    key = event['detail']['file_key']
    bucket = "safeshare-files-chemnitz-99"
    
    s3.delete_object(Bucket=bucket, Key=key)
    return {"status": "deleted"}