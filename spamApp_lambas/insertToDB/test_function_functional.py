"""
 Purpose: test the lambda function That get triggers from S3 and saves into spam response app tables
 Change History:
 
 Change #0001 Humam Nameer: SAI-4 2018-09-12 Initial Push
 Change #0002 Humam Nameer: SAI-5 2018-09-20 Making compatible with zipwhip actual response

 """
# ME SAI-4
import json
import pytest
import os

from mock import Mock, patch
from .function import *

test_data = {
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

def test_standard_run():
	"""
    Tests a complete standard run
    """
	result = lambda_handler(test_data, {})
	assert (result['statusCode'] == 201)
# ME SAI-4
