import json

def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    return("hello world")
