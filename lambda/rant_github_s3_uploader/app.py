import json
import boto3
import uuid
import os
import json

#s3_bucket = os.environ['S3_BUCKET']

def lambda_handler(event, context):

    try:
#        s3 = boto3.resource('s3')
#        s3.Object(
#            s3_bucket,
#            str(uuid.uuid4())).put(Body=json.dumps(event, indent=2)
#        )
        status_code = 200
        message = 'success'
    except:
        status_code = 503
        message = 'failure'

    return {
        "statusCode": status_code,
        "body": json.dumps({
            'message': message,
        })
    }
