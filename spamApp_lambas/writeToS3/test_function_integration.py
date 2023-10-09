"""
 Purpose: test the lambda function for writing event send from zipwhip to s3
 Change History:
 
 Change #0001 Humam Nameer: SAI-3 2018-09-5 Initial Push
 Change #0002 Humam Nameer: SAI-5 2018-09-20 Making compatible with zipwhip actual response

 """
# HN SAI-3
import json
import pytest
#import os
#import boto3
from py_mini_racer import py_mini_racer


#from mock import Mock, patch
from .function import *
# HN SAI-5
test_event = {
         'body':'{\n UUID = "251593B5-D60E-40CA-99F6-9027A85FF122";\n carrierName = "AT&T";\n dateRecieved = "2018-08-07 20:29:56 +0000";\n messageBody = "The world is flat my friend! go to the edge and you will see..";\n sender = "+13168696802";\n}',
         "bodySize":19,
         "visible": "true",
         "hasAttachment":"false",
         "dateRead":"null",
         "bcc":"null",
         "finalDestination":"4257772300",
         "messageType":"MO",
         "deleted":"false",
         "statusCode":"4",
         "id":634151298329219072,
         "scheduledDate":"null",
         "fingerprint":"132131532",
         "messageTransport":"9",
         "contactId":"3382213402",
         "address":"ptn:/4257772222",
         "read":"false",
         "dateCreated":"2015-08-19T16:53:45-07:00",
         "dateDeleted":"null",
         "dateDelivered":"null",
         "cc":"null",
         "finalSource":"4257772222",
         "deviceId":"299538202",
         "test": True
}
# SAI-5
broken_test_event = {
         "body":"{\"dateRecieved\" : ",
         "bodySize":19,
         "visible": "true",
         "hasAttachment":"false",
         "dateRead":"null",
         "bcc":"null",
         "finalDestination":"4257772300",
         "messageType":"MO",
         "deleted":"false",
         "statusCode":"4",
         "id":634151298329219072,
         "scheduledDate":"null",
         "fingerprint":"132131532",
         "messageTransport":"9",
         "contactId":"3382213402",
         "address":"ptn:/4257772222",
         "read":"false",
         "dateCreated":"2015-08-19T16:53:45-07:00",
         "dateDeleted":"null",
         "dateDelivered":"null",
         "cc":"null",
         "finalSource":"4257772222",
         "deviceId":"299538202",
         "test": True
}

def write_to_S3(isBroken):
    """
    Sets event data and call lambda function to store it in test bucket
    """
    if isBroken:
        lambda_caller = lambda_handler(broken_test_event, {})
    else:
        lambda_caller = lambda_handler(test_event, {} )

    return lambda_caller
# HN SAI-5
def read_from_s3():
    s3 = boto3.resource('s3')
    with open('config.json') as fp:
        config = json.load(fp)
    
    js = py_mini_racer.MiniRacer()
    js.eval(test_event['body'])
    try:
        UUID = js.eval('UUID') if type(js.eval('UUID')) is str else "Missing-UUID" 
        obj = s3.Object(config["test_bucket_name"], 'ios/'+ UUID + '/' + test_event['dateCreated']+'_'+str(test_event['id'])+'.json')
        file_content = obj.get()['Body'].read().decode('utf-8')
        print()
    except Exception as ex:
        err_msg = f"Could not read from s3 for reason 1 : [{str(ex)}]"
        print(err_msg)
        return teardown_s3_contents()
        
          
    return json.loads(file_content)
# SAI-5
def teardown_s3_contents():
    s3 = boto3.resource('s3')
    with open('config.json') as fp:
        config = json.load(fp)
    bucket = s3.Bucket(config["test_bucket_name"])
    try:
        bucket.objects.all().delete()
    except Exception as ex:
        err_msg = f"Could not delete from s3 for reason: [{str(ex)}]"
        print(err_msg)
        return {
            "status": 500,
            "body": "delete failed"
        }

    return {
        "status": "200",
        "body": "successfully deleted"
    }

def test_lambda_handler():
    lambda_caller = write_to_S3(False)
    file_content = read_from_s3()
    teardown_s3_contents()

    assert(test_event == file_content)

def read_from_Error_s3():
        s3 = boto3.resource('s3')
        with open('config.json') as fp:
            config = json.load(fp)
    
        try:
            obj = s3.Object(config["test_bucket_name"], 'ios/Error_Bucket/' + broken_test_event['dateCreated'] +'_'+str(broken_test_event['id'])+'.txt')
            file_content = obj.get()['Body'].read().decode('utf-8')
        except Exception as ex:
            err_msg = f"Could not read from s3 for reason 2 : [{str(ex)}]"
            print(err_msg)
            return teardown_s3_contents()
        
        return file_content


def test_broken_json_lambda_handler():
    lambda_caller = write_to_S3(True)
    file_content = read_from_Error_s3()
    teardown_s3_contents()

    assert(str(broken_test_event) == str(file_content))


# SAI-3
