"""
 Purpose: the lambda function for writing event send from zipwhip to s3
 Change History:
 
 Change #0001 Humam Nameer: SAI-3 2018-09-5 Initial Push
 Change #0002 Humam Nameer: SAI-4 2018-09-11 Adding test key where all test item should go
 Change #0003 Humam Nameer: SAI-5 2018-09-20 Making compatible with zipwhip actual response
 Change #0004 Humam Nameer: SAI-42 2018-10-16 Reporting spam via https endpoint from the ios extension

"""
import json
import uuid
import pymysql
import logging
import requests
import boto3

# HN: SAI-3
# HN SAI-5
# HN: SAI-42
def lambda_handler(event, context):
    
    """
    Main function executed by the Lambda
    :param event: dict Provided by Lambda; at a minimum, needs to have ['requestContext']['resourcePath']
    and ['queryStringParameters'] fields
    :param context: dict Provided by Lambda; unused in the present script
    :return:
    """
    print(event)
    try: 
        s = json.dumps(event['body'])
        body = json.loads(s)
        print(body)     

    except Exception as ex:
        err_msg = f"Could not connect to the s333 for reason: [{str(ex)}]"
        logging.error(err_msg)
        return {
                "isBase64Encoded": False,
                "statusCode": 500,
                "body": "upload failed"
            }

# HN: SAI-4
    with open('config.json') as fp:
        config = json.load(fp)
    bucket_name = config['test_bucket_name'] if event.get("test") is True else config['bucket_name']
    bucket_key_prefix = 'ios/tests/' if event.get('dbLambda') is True else 'ios/'
    try:
        client = boto3.client('s3')
        body = json.loads(body)
        UUID = body['classification']['UUID'] if type(body['classification']['UUID']) is str else "Missing-UUID" 
        event_date = body['classification']['dateReported'] if type(body['classification']['dateReported']) is str else "Missing-Date"
        for i in range(len(body['classification']['dateRecieved'])):
            dump = {}
            dump['carrierName']=body['classification']['carrierName']
            dump['messageBody']=body['classification']['messageBody'][i]
            dump['sender']=body['classification']['sender']
            dump['dateRecieved']=body['classification']['dateRecieved'][i]
            dump['UUID']= body['classification']['UUID']
            dump['dateReported']=body['classification']['dateReported']
            client.put_object(Body=json.dumps(dump), Bucket= bucket_name, ContentType= "application/json", Key= bucket_key_prefix+ UUID + '/' + event_date.replace(" ", "") +'_'+str(i) +'.json')

    except Exception as ex:
        err_msg = f"Could not connect to the s3 for reason: [{str(ex)}]"
        logging.error(err_msg)
        return {
            "isBase64Encoded": False,
            "statusCode": 500,
            "body": "upload failed"
        }

    return {
        "isBase64Encoded": False,
        "statusCode": 201,
        "body": "uploaded Successfully"
    }
# HN: SAI-3
# SAI-4
# SAI-5
# SAI-42