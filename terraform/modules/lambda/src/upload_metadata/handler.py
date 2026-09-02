import boto3
import os

def handler(event, context):
    table = boto3.resource('dynamodb').Table('safeshare-tokens')
    obj = event['detail']['object']
    
    table.put_item(Item={
        'token': obj['key'],
        'size': obj['size'],
        'type': 'uploaded'
    })
    return {"status": "saved"}