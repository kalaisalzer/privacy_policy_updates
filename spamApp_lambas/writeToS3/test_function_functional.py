"""
 Purpose: test the lambda function for writing event send from zipwhip to s3
 Change History:
 
 Change #0001 Humam Nameer: SAI-3 2018-09-5 Initial Push
 """
# ME SAI-3
import json
import pytest
import os

from mock import Mock, patch
from .function import *

test_data = {
     "body":"{\"dateRecieved\" : \"2018-08-07 20:29:56 +00000\", \"region\" : \"US\", \"messageBody\" : \"The world is flat my friend! go to edge and you will see ..\", \"sender\" : \"+13168696802\", \"dateReported\": \"2018-08-07 20:29:56 +00000\", \"carrier\": \"AT&T\", \"UUID\": \"UUID-5654-0019-2067\"}",
         "bodySize":19,
         "visible": "true",
         "hasAttachment":"false",
         "dateRead":"null",
         "bcc":"null",
         "finalDestination":"4257772300",
         "messageType":"MO",
         "deleted":"false",
         "statusCode":"4",
         "id":"634151298329219072",
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

def test_standard_run():
	"""
    Tests a complete standard run
    """
	result = lambda_handler(test_data, {})
	assert (result['statusCode'] == 201)
# ME SAI-3
