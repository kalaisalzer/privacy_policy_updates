# WRITE TO S3 (SAI)

This Lambda is the handler to write to s3. It is paired with an API Gateway instance.

curl -X POST https://api.zipwhip.com/webhook/add -d session=2b67d615-2b7b-43a8-a89b-55999e7267a4:378132503 -d type=message -d event=receive -d url=https://e9d08c3hzf.execute-api.us-east-1.amazonaws.com/dev/spa-ios-write-to-s3 -d method=POST