"""
 Purpose: test the lambda function That get triggers from S3 and saves into spam response app tables
 Change History:
 
 Change #0001 Humam Nameer: SAI-4 2018-09-12 Initial Push
 Change #0002 Humam Nameer: SAI-5 2018-09-20 Making compatible with zipwhip actual response
 """

import json
import pytest
import os
import boto3
import uuid
import pymysql
import logging
import requests
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import sys
from pathlib import Path
import time
from py_mini_racer import py_mini_racer

# This is very messy - if anyone ever finds a better way, let me know. :)
# It's the only way I've found to allow tests to import from directories
# several levels up and over...
TOP_DIR = str(Path(__file__).resolve().parents[2])
sys.path.insert(0, TOP_DIR)

from writeToS3.function import * 
from insertToDB.models import *


# HN SAI-4
# HN SAI-5
test_event = {
	"body": "{\n    UUID = \"251593B5-D60E-40CA-99F6-9027A85FF122\";\n    carrierName = \"AT&T\";\n    dateRecieved = \"2018-08-07 20:29:56 +0000\";\n    dateReported = \"2018-09-20 21:30:59 +0000\";\n    messageBody = \"The world is flat my friend! go to the edge and you will see..\";\n    sender = \"test\";\n}",
    	"bodySize": 289,
    	"visible": True,
    	"hasAttachment": False,
    	"dateRead": "null",
    	"bcc": "null",
    	"finalDestination": "8333272234",
    	"messageType": "MO",
    	"deleted": False,
    	"statusCode": 4,
    	"id": 1042888895314968576,
    	"scheduledDate": "null",
    	"fingerprint": "461513614",
    	"messageTransport": 5,
    	"contactId": 14103390003,
	    "address": "ptn:/5715241902",
    	"read": False,
	    "dateCreated": "2018-09-20T14:31:03-07:00",
    	"dateDeleted": "null",
	    "dateDelivered": "null",
	    "cc": "null",
	    "finalSource": "5715241902",
	    "deviceId": 378132503,
        "dbLambda": True
}
 
def setup_insert_to_table():
    """ 
    Tests if the insert to DB lambda was triggered and entry was added in the table
    """
    session = None
    with open('config.json') as fp:
        config = json.load(fp)
        engine = create_engine('mysql+pymysql://' + config['db']['username']+ ':' + config['db']['password'] + '@' + config['db']['host']+':'+str(config['db']['port'])+ '/' +config['db']['db'] + '?charset=utf8')
        Session = sessionmaker(bind=engine)
        session = Session()
    return session


def write_to_S3(isBroken):
    """
    Sets event data and call lambda function to store it in test bucket
    """
    if isBroken:
        lambda_caller = lambda_handler(broken_test_event, {})
    else:
        lambda_caller = lambda_handler(test_event, {} )

    return lambda_caller

def read_from_s3():
    s3 = boto3.resource('s3')
    js = py_mini_racer.MiniRacer()
    js.eval(test_event['body'])
    with open('config.json') as fp:
        config = json.load(fp)

    try:
        UUID = js.eval('UUID') if type(js.eval('UUID')) is str else "Missing-UUID" 
        obj = s3.Object(config["bucket_name"], 'ios/tests/'+ UUID + '/' + test_event['dateCreated']+'_'+str(test_event['id'])+'.json')
        file_content = obj.get()['Body'].read().decode('utf-8')
        print()
    except Exception as ex:
        err_msg = f"Could not read from s3 for reason 1 : [{str(ex)}]"
        print(err_msg)
        return teardown_s3_contents()
        
          
    return json.loads(file_content)

def teardown_s3_contents():
    s3 = boto3.resource('s3')
    with open('config.json') as fp:
        config = json.load(fp)
    bucket = s3.Bucket(config["bucket_name"])
    try:
        objs = bucket.objects.filter(Prefix='ios/tests/')
        for obj in objs:
            obj.delete()
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
    time.sleep(10)
    teardown_s3_contents()
    assert(test_event == file_content)
    session = setup_insert_to_table()
    entry = session.query(RawSpamResponseApp).filter(RawSpamResponseApp.SenderAddress == "test").filter(RawSpamResponseApp.AppSource == "iOS").all()
    assert(len(entry) == 1)
    session.query(RawSpamResponseApp).filter(RawSpamResponseApp.SenderAddress == "test").filter(RawSpamResponseApp.AppSource == "iOS").delete()
    session.commit()
    session.close()



# SAI-4
# SAI-5
