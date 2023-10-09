## ReadMe:

[ ] download the file attached along this file named: GoDaddy-Abuse.postman_collection.json

# Steps to install API Development Environment (Postman).
Note: You do NOT have to sign in / sign up to use postman
1. Download Postman from https://www.getpostman.com/apps
2. Open Postman and from top menu select File then import.
3. Drag and drop the file GoDaddy-Abuse.postman_collection.json and click import.
4. On your left panel select the tab Collection.
5. Expand the collection GoDaddy-Abuse to view all API'select

## Create Abuse Ticket:

following are the types you can select for Abuse "type": 
"A_RECORD", "CHILD_ABUSE", "CONTENT", "FRAUD_WIRE", "IP_BLOCK", "MALWARE", "NETWORK_ABUSE", "PHISHING", "SPAM"

Collection contains two samples of this apis:
Create Phishing abuse ticket and Create Spam Abuse ticket, In body you can replace type from any of the options given above.

## Get Tickets List by Filters:
following are the type of filters you can use to list created tickets:
    "closed", "closedAt", "createdAt", "domainIp", "reporter", "source", "target", "ticketId", "type"
    
Once you have created multiple tickets you can view them from this api.
In collection we have on case as such with applied filters closed and type.

## Get particular ticket Info:

The collection contains a sample api "Get Particular Ticket" with ticket id 'DCU000647113'.
Replace the ticket id with your ticket id and hit send to get information about your ticket.

