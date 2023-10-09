import boto3
import pymysql
import datetime
from time import sleep
import json
from urlparse import urlparse
from GetAttackStructure import get_attack_structure


def handleNewlines(data):
    datalist = []
    dsplit = data.split('|||')
    count = 0
    tempstr = ''
    for d in dsplit:
        count += 1
        if count == 6:
            nlsplit = d.split('\n')
            tempstr = tempstr + '|||' + nlsplit[0]
            datalist.append(tempstr)
            count = 1
            if len(nlsplit) > 1:
                tempstr = nlsplit[1]
            else:
                tempstr = ''
        else:
            if tempstr:
                tempstr = tempstr + '|||' + d
            else:
                tempstr = d 

        
    return datalist

def getFieldsFromText(body):

    dd_list = []

    #newline_split = body.split('\n')

    newline_split = handleNewlines(body)

    for newline in newline_split:

        body_split = newline.split('|||')

        if len(body_split) > 2:

            try:

                data_dict = {'carrier':body_split[0], 'msg_datetime':body_split[1], 'sender':body_split[2],
                     'text':body_split[3].replace("'","\\'"),
                     'reported_datetime':body_split[4],'reporter_id':body_split[5].replace("'","\\'")}

                dd_list.append(data_dict)

            except:
                pass

    return dd_list

def convertDate(input_date):
    try:
        format1 = '%Y-%m-%d %I:%M:%S %p'
        my_date = datetime.datetime.strptime(input_date, format1)

        format2 = '%Y-%m-%d %H:%M:%S'
        new_date = my_date.strftime(format2)
    except Exception as e:
        print('error getting new date' +  str(e))
        new_date = ''

    return new_date

def lambda_handler(event, context):


    with open('lambda.json') as fp:
        raw_data = json.load(fp)

    
    key = '1'
    s3 = boto3.client('s3')

    e = 'hi'
    sleep(1)

    '''
    records = event['Records']
    keys = []
    s3_obj = boto3.resource('s3')

    for record in records:
       keys.append(record['s3']['object']['key'])    
    
    for key in keys:
        try: 
            obj = s3_obj.Object(raw_data["bucket"], unquote(key))
            file_content = obj.get()['Body'].read().decode('utf-8')
            print file_content
        except Exception as ex:
            #err_msg = f"Could not read from s3 for reason 1 : [{str(ex)}]"
           
            return {
                "isBase64Encoded": False,
                "statusCode": 500,
                "body": event
            }
    '''
    key = str(event['Records'][0]['s3']['object']['key'])
    key = urlparse.unquote(key)

    response = s3.get_object(Bucket=raw_data['bucket'], Key=key)
    

    filename = str(event['Records'][0]['s3']['object']['key'])
    print response['Body']
    # #filename = 'testfilecjn.txt'

    # data_list = getFieldsFromText(response['Body'].read().decode())
    
    #data1 = {'carrier':'Sprint', 'msg_datetime':'2018-10-05 12:12:00 PM', 'sender':'4041112222',
    #                 'text':'This is a test l number is 3312229988',
    #                 'reported_datetime':'2018-10-05 12:12:00 PM','reporter_id':'AAA'}

    #data_list = [data1]

    db = pymysql.connect(
        user=raw_data['user'],password=raw_data['password'],
        db=raw_data['db'],host=raw_data['host'],
        port=int(raw_data['port']), cursorclass=pymysql.cursors.DictCursor)
    db.autocommit(True)
    cur = db.cursor()
    cur.execute('SET NAMES utf8;')
    cur.execute('SET CHARACTER SET utf8;')
    cur.execute('SET character_set_connection=utf8;')
    for data in data_list:
        attack_structure, phos, emails, url_dict, url_dom_dict = get_attack_structure(data['text'])
        print 'attack structure is', attack_structure
        print 'cta dict is', url_dict
        #raw_input()
        td_received = convertDate(data['msg_datetime'])
        td_reported = convertDate(data['reported_datetime'])
        cur.execute("INSERT INTO " + raw_data['db'] + ".raw_spam_response_app (AppSource, YourCarrier, MsgDatetime, SenderAddress, SpamMsgText, ReportDatetime,ReporterID, TimeDateReceived, TimeDateReported, InsertDate, FileName, attack_structure) VALUES ('iOS'," + data['carrier'] + "', '" + data['msg_datetime'] + "', '" + data['sender'] + "', '" + data['text'] + "', '" + data['reported_datetime'] + "', '" + data['reporter_id'] + "', '" + td_received + "', '" + td_reported + "', NOW(), '" + str(filename) + "', '" + attack_structure + "')")
        cur.execute("SELECT LAST_INSERT_ID();")
        table_id = cur.fetchall()[0]['LAST_INSERT_ID()']
        #print table_id
        used_url = []
        try:
            for p in phos:
               #cur.execute("INSERT INTO " + att_7726_db + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + p.replace("'","''") + "', '2')")
               cur.execute("INSERT INTO " + raw_data['db'] + ".app_data_cta (WMCGReportID, cta, cta_type) VALUES ('" + str(table_id) + "', '" + p.replace("'","''") + "', '2')")
            for e in emails:
                #cur.execute("INSERT INTO " + att_7726_db + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + e.replace("'","''") + "', '1')")
                 cur.execute("INSERT INTO " + raw_data['db'] + ".app_data_cta (WMCGReportID, cta, cta_type) VALUES ('" + str(table_id) + "', '" + e.replace("'","''") + "', '1')")
            for u in url_dict:
                 if u not in used_url:
                     used_url.append(u)
                     #cur.execute("INSERT INTO " + att_7726_db + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + u.replace("'","''") + "', '3')")
                                                
                     cur.execute("INSERT INTO " + raw_data['db'] + ".app_data_cta (WMCGReportID, cta, cta_type, starting_url, redirects, landing_page_domain) VALUES ('" + str(table_id) + "', '" + u.replace("'","''") + "', '3', '" + str(u).replace("'","''") + "','" + str(','.join(url_dict[u])).replace("'","''") + "' , '" + url_dom_dict[u].replace("'","''") + "')")
                                            
                     #if u.replace("'","''") != url_dom_dict[u].replace("'","''"):
                     #    cursor.execute("INSERT INTO " + raw_data['db'] + ".staging_cta (stg_id, cta, cta_type) VALUES ('" + str(ids[0]) + "', '" + url_dom_dict[u].replace("'","''") + "', '3')")

        except Exception as e2:
            print 'error inserting domain in cta db', e2
    print'calling the stored procedure'
    cur.execute("call " + raw_data['spam_portal_db'] + ".ingest_spam_grouped('" + str(table_id) + "', '" + data['sender'] + "', '" + data['text'] + "', '" + data['reported_datetime'] + "', '10', '" + attack_structure + "');")
    #print cursor.fetchall()
    cur.close()
    

lambda_handler(1, 2)
