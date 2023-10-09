"""
 Purpose: the lambda function That get triggers from S3 and saves into spam response app tables
 Change History:
 
 Change #0001 Humam Nameer: SAI-4 2018-09-12 Initial Push
 Change #0002 Humam Nameer: SAI-5 2018-09-20 Making compatible with zipwhip actual response
 Change #0003 Humam Nameer: SAI-42 2018-10-16 Reporting spam via https endpoint from the ios extension

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
from GetAttackStructure import get_attack_structure
from sqlalchemy.pool import NullPool

# HN: SAI-4
# HN: SAI-5
# HN: SAI-42
def insert_to_tables(file_content, key, session, config):
    """
    Function that inserts whatever it gets into spam response tables
    :param file_content: file that was uploaded to s3
    :param key: the relative path to the file inside the bucket
    :param session: sqlalcheny session
    :return:
    """

    try:
        print(type(file_content))
        s3_record = json.loads(file_content)
        
    except Exception as ex:
        err_msg = f"Not posting to DB Json is malformed wiith error: [{str(ex)}]"
        logging.error(err_msg)
        return {
            "isBase64Encoded": False,
            "statusCode": 500,
            "body": ''
        }
    try: 
        time_date_reported= datetime.strptime(s3_record['dateReported'], '%Y-%m-%d %H:%M:%S %z')
    except Exception as ex:
        time_date_reported = datetime.strptime('1970-01-01 00:00:00 +0000', '%Y-%m-%d %H:%M:%S %z')
    try:
        message_date_time= datetime.strptime(s3_record['dateRecieved'], '%Y-%m-%d %H:%M:%S %z')
    except Exception as ex:
        message_date_time = datetime.strptime('1970-01-01 00:00:00 +0000', '%Y-%m-%d %H:%M:%S %z')

    message_carrier = s3_record['carrierName'] if type(s3_record['carrierName']) is str else ''
    message_sender = s3_record['sender'] if type(s3_record['sender']) is str else ''
    message_msg_body = s3_record['messageBody'] if type(s3_record['messageBody']) is str else ''
    message_uuid = s3_record['UUID'] if type(s3_record['UUID']) is str else ''

    new_entry = RawSpamResponseApp(AppSource="iOS",
        YourCarrier=message_carrier,
        MsgDatetime=message_date_time.strftime('%Y-%m-%d %I:%M:%S %p'),
        SenderAddress=message_sender,
        SpamMsgText=message_msg_body.strip("\""),
        ReportDatetime=time_date_reported.strftime('%Y-%m-%d %I:%M:%S %p'),
        TimeDateReceived = message_date_time,
        TimeDateReported = time_date_reported,
        FileName=unquote(key),
        ReporterID=message_uuid
        )
    session.add(new_entry)
    session.commit()

    attack_structure, phos, emails, url_dict, url_dom_dict = get_attack_structure(message_msg_body)
    print('attack structure is = %s' % attack_structure) 
    print('cta dict is = %s' % url_dict)
    res = session.execute("SELECT LAST_INSERT_ID();")
    table_id = res.fetchall()[0]['LAST_INSERT_ID()']
    used_url = []
    try:
        for p in phos:
            #cur.execute("INSERT INTO " + att_7726_db + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + p.replace("'","''") + "', '2')")
            session.execute("INSERT INTO " + config['db']['db'] + ".app_data_cta (WMCGReportID, cta, cta_type) VALUES ('" + str(table_id) + "', '" + p.replace("'","''") + "', '2')")
        for e in emails:
            #cur.execute("INSERT INTO " + att_7726_db + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + e.replace("'","''") + "', '1')")
            session.execute("INSERT INTO " + config['db']['db'] + ".app_data_cta (WMCGReportID, cta, cta_type) VALUES ('" + str(table_id) + "', '" + e.replace("'","''") + "', '1')")
        for u in url_dict:
            if u not in used_url:
                used_url.append(u)
                #cur.execute("INSERT INTO " + att_7726_db + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + u.replace("'","''") + "', '3')")
                                                
                session.execute("INSERT INTO " + config['db']['db'] + ".app_data_cta (WMCGReportID, cta, cta_type, starting_url, redirects, landing_page_domain) VALUES ('" + str(table_id) + "', '" + u.replace("'","''") + "', '3', '" + str(u).replace("'","''") + "','" + str(','.join(url_dict[u])).replace("'","''") + "' , '" + url_dom_dict[u].replace("'","''") + "')")
                                            
                #if u.replace("'","''") != url_dom_dict[u].replace("'","''"):
                #    cursor.execute("INSERT INTO " + raw_data['db'] + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + url_dom_dict[u].replace("'","''") + "', '3')")

    except Exception as e2:
        err_msg = f"error inserting domain in cta db [{str(e2)}]"
        print(err_msg)
    print('calling the stored procedure')
    session.execute("call " + config['db']['spam_portal_db'] + ".ingest_spam_grouped('" + str(table_id) + "', '" + message_sender + "', '" + message_msg_body + "', '" + time_date_reported + "', '10', '" + attack_structure + "');")
    #print cursor.fetchall()
    session.commit()
    new_json_entry = SpamResponseJson(uuid=message_uuid.encode(), json_blob=file_content, msg_timestamp=message_date_time.strftime('%Y-%m-%d %I:%M:%S %p'))
    session.add(new_json_entry)
    session.commit()
 # SAI-5   

def lambda_handler(event, context):
    """
    Main function executed by the Lambda
    :param event: dict Provided by Lambda;
    :param context: dict Provided by Lambda; unused in the present script
    :return:
    """

    with open('config.json') as fp:
        config = json.load(fp)
    connection_string = 'mysql+pymysql://' + config['db']['username']+ ':' + config['db']['password'] + '@' + config['db']['host']+':'+str(config['db']['port'])+ '/' +config['db']['db']+ '?charset=utf8mb4'
    print("connection string")
    print(connection_string)
    try:
        engine = create_engine(connection_string,  encoding='utf8', poolclass=NullPool)
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
    #_objects = session.query(RawSpamResponseApp).first()
    #print("_object= %s" % str(_objects))
    print(event)
    records = event['Records']
    keys = []
    s3_obj = boto3.resource('s3')

    for record in records:
       keys.append(record['s3']['object']['key'])    
    
    for key in keys:
        try: 
            print(config["bucket_name"], unquote(key))
            obj = s3_obj.Object(config["bucket_name"], unquote(key))
            file_content = obj.get()['Body'].read().decode('utf-8')
            
        except Exception as ex:
            err_msg = f"Could not read from s3 for reason 1 : [{str(ex)}]"
            print(err_msg)
            return {
                "isBase64Encoded": False,
                "statusCode": 500,
                "body": event
            }
        insert_to_tables(file_content, key, session, config)
        session.close()
        conn = engine.connect()
        conn.invalidate()
        engine.dispose()
        print("everything ran !!")
    return {
        "isBase64Encoded": False,
        "statusCode": 201,
        "body": event
    }
# HN: SAI-4
#HN: SAI-42