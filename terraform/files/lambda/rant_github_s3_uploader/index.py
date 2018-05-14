import json
import boto3
import uuid
import os

def handler(event, context):
    s3_bucket = os.environ['S3_BUCKET']
    try:
        s3 = boto3.resource('s3')
        s3.Object(
            s3_bucket,
            str(uuid.uuid4())).put(Body=json.dumps(event, indent=2)
        )
        return 'Event stored'
    except:
        raise
