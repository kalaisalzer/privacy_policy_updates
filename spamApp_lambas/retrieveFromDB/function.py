"""
 Purpose: the lambda function that retrieves result from table for particular app uuid
 Change History:
 
 Change #0001 Humam Nameer: SAI-42 2018-10-08 Initial Push
 Change #0002 Humam Nameer: SAI-60 2018-10-22 Getting list in descending order.

 """
import json
import uuid
import pymysql
import logging
import requests
import boto3
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import *
from urllib.parse import unquote
from datetime import datetime
from sqlalchemy.pool import NullPool


# HN: SAI-42
# HN: SAI-60 
def insert_to_tables(_uuid, session):
    """
    Function that retrieve spam response tables for particular uuid
    :param _uuid: query parameter
    :param session: sqlalcheny session
    :return: list of entries
    """
    
    try:
        combined_reqs = []
        spam_objs = session.query(RawSpamResponseApp).filter(RawSpamResponseApp.ReporterID == _uuid).order_by(RawSpamResponseApp.ReportDatetime.desc())
        session.commit()
        session.close()
        combined_reqs.extend(spam_objs)
        history_list = []
        for req in combined_reqs:
            tmp_dict = {'id': req.ID,
                'msgDateTime': req.MsgDatetime,
                'senderAddress': req.SenderAddress,
                'msgText': req.SpamMsgText,
                'msgReportTime': req.ReportDatetime
            }
            history_list.append(tmp_dict)
            
        return history_list
        
    except Exception as ex:
        try:
            session.close()
            
        except Exception as exx:
            pass
        err_msg = f"Not retrieving to DB Json is malformed with error: [{str(ex)}]"
        logging.error(err_msg)
        return {
            "isBase64Encoded": False,
            "statusCode": 500,
            "body": ''
        }
 # SAI-60   
 

def lambda_handler(event, context):
    """
    Main function executed by the Lambda
    :param event: dict Provided by Lambda;
    :param context: dict Provided by Lambda; unused in the present script
    :return:
    """

    with open('config.json') as fp:
        config = json.load(fp)
    connection_string = 'mysql+pymysql://' + config['db']['username']+ ':' + config['db']['password'] + '@' + config['db']['host']+':'+str(config['db']['port'])+ '/' +config['db']['db']
    print("connection string")
    print(connection_string)
    try:
        engine = create_engine(connection_string, poolclass=NullPool)
        Session = sessionmaker(bind=engine)
        session = Session() 
    except Exception as ex:
        err_msg = f"Could not connect to the database for reason: [{str(ex)}]"
        logging.error(err_msg)
        return {
            "isBase64Encoded": False,
            "statusCode": 500,
            "body": ''
        }
    uuid = event['queryStringParameters']['uuid']
    history_list = insert_to_tables(uuid, session)
    engine.dispose()
  
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": json.dumps({"records": history_list})
    }
# HN: SAI-42