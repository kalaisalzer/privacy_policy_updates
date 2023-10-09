"""
 Purpose: the lambda function that retrieves result from table for particular app uuid
 Change History:
 
 Change #0001 Humam Nameer: SAI-42 2018-10-08 Initial Push

//sqlacodegen mysql+pymysql://portal_test:'*b&JC6lX^fhU'@dev.c37y9ifr9vt2.us-east-1.rds.amazonaws.com:9036/spam_portal_db > foo.py
"""
#HN: SAI-42
# coding: utf-8
from sqlalchemy import CHAR, Column, DateTime, ForeignKey, String, TIMESTAMP, Table, Text, VARBINARY, text
from sqlalchemy.dialects.mysql import INTEGER
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
metadata = Base.metadata


t_raw_spam_response = Table(
    'raw_spam_response', metadata,
    Column('ID', String(10)),
    Column('YourCarrier', String(50)),
    Column('SpamType', String(50)),
    Column('SpamMsgText', Text),
    Column('SenderAddress', Text),
    Column('DateReceivedRaw', Text),
    Column('TimeReceivedRaw', Text),
    Column('TimeDateReceived', DateTime),
    Column('InsertDate', TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP")),
    Column('region', String(15))
)


t_raw_spam_response_Copy = Table(
    'raw_spam_response_Copy', metadata,
    Column('ID', String(10)),
    Column('YourCarrier', String(50)),
    Column('SpamType', String(50)),
    Column('SpamMsgText', Text),
    Column('SenderAddress', Text),
    Column('DateReceivedRaw', Text),
    Column('TimeReceivedRaw', Text),
    Column('TimeDateReceived', DateTime),
    Column('InsertDate', TIMESTAMP, nullable=False, server_default=text("'0000-00-00 00:00:00'")),
    Column('region', String(15))
)


class RawSpamResponseApp(Base):
    __tablename__ = 'raw_spam_response_app'

    ID = Column(INTEGER(11), primary_key=True)
    AppSource = Column(String(40), nullable=False, server_default=text("'Android'"))
    YourCarrier = Column(String(50))
    MsgDatetime = Column(Text)
    SenderAddress = Column(Text)
    SpamMsgText = Column(Text)
    ReportDatetime = Column(Text)
    ReporterID = Column(Text)
    TimeDateReceived = Column(DateTime)
    TimeDateReported = Column(DateTime)
    InsertDate = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))
    FileName = Column(Text)
    attack_structure = Column(Text)
    attack_structure_hash = Column(CHAR(64), index=True)


class SpamResponseJson(Base):
    __tablename__ = 'spam_response_json'

    id = Column(INTEGER(11), primary_key=True)
    uuid = Column(VARBINARY(40), nullable=False, index=True)
    json_blob = Column(Text, nullable=False)
    msg_timestamp = Column(Text)
    insert_date = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))


class AppDataCta(Base):
    __tablename__ = 'app_data_cta'

    id = Column(INTEGER(11), primary_key=True)
    WMCGReportID = Column(ForeignKey('raw_spam_response_app.ID'), nullable=False, index=True)
    cta = Column(String(500), nullable=False, index=True)
    cta_type = Column(INTEGER(11))
    starting_url = Column(Text)
    redirects = Column(Text)
    landing_page_domain = Column(Text)
    insert_date = Column(TIMESTAMP, nullable=False, server_default=text("CURRENT_TIMESTAMP"))

    raw_spam_response_app = relationship('RawSpamResponseApp')
#SAI-42