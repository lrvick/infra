import json

def handler(event, context):
    if event["source"] != "aws.ecs":
       raise ValueError("Function only supports input from events with a source type of: aws.ecs")
    print('Here is the event:')
    print(json.dumps(event))
