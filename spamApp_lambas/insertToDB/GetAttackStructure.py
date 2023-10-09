from bs4 import BeautifulSoup
#import BeautifulSoup
import re, requests
from urllib.parse import urlparse
from requests.exceptions import ConnectionError, InvalidSchema, Timeout, TooManyRedirects
from time import sleep
#import html5lib
import json
import pymysql

def getListOfRedirectUrls(url, ua):
    #print 'ua is', ua
    if ua == 1:
        user_agent = ''
    else:
        user_agent='Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; SCH-I535 Build/KOT49H) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30'
    #print 'user agent is', user_agent
    #print "starting getListOfRedirectUrlsAndLandingPageText with", url
    try:
        redirects = []
        shortcutted = False


        get = True
        requestAttempts = 0
        while get:
            requestAttempts += 1
            if requestAttempts > 20:
                break
            if '.ipsw' in url:
                break
            try:
                #print 'while'
                if url.startswith("mailto:"):
                    redirects.append(url)
                    break
                elif not url.startswith("http"):
                    url = re.sub(r"^[^:]*(?=:\/\/)","http",url)
                # we use a user agent string because some websites will block you if you don't have one
                #print "about to requests", url
                # set verify=False, to not verify https ssl certs, because outbrain does weird stuff that throws an error
                #print "will try to request"
                get = False
                if user_agent:
                    request = requests.get(url, allow_redirects=True, timeout=5, headers={'User-Agent': user_agent}, verify=False)
                    #print 'using ua'
                else:
                    request = requests.get(url, allow_redirects=True, timeout=5, verify=False)
                    #print 'no ua'
                #print "got it"

                #print "\nrequest is", request.text
                redirects.extend([r.url for r in request.history])
                redirects.append(request.url)
                #print "reds are now", redirects
                #print 'headers are', request.headers
                if ("content-type" in request.headers and "text/html" in request.headers['content-type']) or 'outbrain' in url:
                    # capture redirects via meta refresh tag
                    #print 'found content type'
                    try:
                        soup = BeautifulSoup(request.text.lower().replace('<noscript>',''))
                    except:
                        pass
                        #soup = BeautifulSoup(request.text.lower().replace('<noscript>',''), 'html5lib')

                    # try to get next redirect via meta refresh tag
                    metas = soup.find_all("meta", attrs={"http-equiv": "refresh"})
                    #print "metas are", len(metas)
                    if metas:
                        #print 'found metas'
                        for meta in metas:
                            content = meta['content']
                            url = re.search(r"(?<=URL=)[^;]+", content, re.IGNORECASE).group(0)
                            get = True

                    #if not already getting the next page via meta-refresh, try to see if redirect in body's onload
                    if not get:
                        try:
                            soup = BeautifulSoup(request.text.lower().replace('<noscript>',''))
                        except:
                            pass
                            #soup = BeautifulSoup(request.text.lower().replace('<noscript>',''), 'html5lib')

                        #print 'get is false...'
                        # capture redirects via javascript onbodyload, which Outbrain uses
                        body = soup.find("body", attrs={"onload": re.compile("document.location.replace")})
                        #print "body is", body
                        if body:
                            onload = body['onload']
                            search = re.search("document.location.replace\('(?P<url>[^']*)'\)", onload)
                            #print "search is", search
                            if search:
                                # gets the url and replaces escaped / with just a regular /
                                url = search.group("url").replace("\\/", "/")
                                #print "url is", url
                                get = True
            except Timeout:
                #print "timed out"
                pass
            except TooManyRedirects:
                #print "exceeded redirects"
                pass
            except ConnectionError as e:
                message = str(e)
                if "[Errno -2] Name or service not known)" in message:
                    print("Caught Name or service not known error. This usually happens because the webpage that the url is directing us to doesn't exist")
                else:
                    print("message ") 
                    pass
            except Exception as e:
                print(e) 
                pass


        #print "finishing getListOfRedirectUrlsAndLandingPageText"

        

            return redirects
        else:
            return redirects



    except Exception as e:
        #print "caught this exception in getRedirect....", e
        return [url]

def get_ctas(body):

    bsplit = body.split(' ')

    phos  = re.findall("(\d{3}[-\.\s]??\d{3}[-\.\s]??\d{4}|\(\d{3}\)\s*\d{3}[-\.\s]??\d{4}|\d{3}[-\.\s]??\d{4})", body)
    emails = re.findall("[\w\.-]+@[\w\.-]+", body)
    urls = re.findall('https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+', body)
    urls2 = re.findall('[\w\.-]+\.[\w\.-]+', body)

    bad_urls = []
    for email in emails:
        e_split = email.split('@')
        if len(e_split) > 1:
            bad_urls.append(e_split[1])

    for u in urls2:
        u2 = 'http://' + u
        u3 = 'https://' + u
        if u not in bad_urls and u2 not in urls and u3 not in urls and '..' not in u:
            urls.append(u)

    final_urls = []
    for u in urls:
        for bs in bsplit:
            if u in bs and bs not in final_urls:
                final_urls.append(bs)
            else:
                if u not in final_urls:
                    final_urls.append(u.strip())
    
    final_urls = substringS(final_urls)

    final_phos = []
    for p in phos:
        num_in_url = False
        for f in final_urls:
            if p in f:
                num_in_url = True
        if not num_in_url:
            final_phos.append(p.strip())

    return final_phos, emails, final_urls

def substringS(string_list):
    out = []
    dom_endings = ['.co','.edu','net','.gl','.ly', 'http', '.io', '/', '.info',
    '.win', '.org', '.cricket', '.accountant', '.online', '.xyz', '.date','.us', 
    '.live','space','.me']
    cash = []
    for s in string_list:
        if s not in out and any(d in s.lower() for d in dom_endings):
            out.append(s)

    out2 = []
    for s in out:
        money = re.findall('.*\.\d\d', s)
        if not money:
            out2.append(s)

    out3 = []
    for o in out2:
        if not any([o in r for r in out2 if o != r]):
            out3.append(o)
    
        
    return out3

def get_dom(u):
    if '://' in u:
        usplit = u.split('://')
        u = usplit[1]
    elif '://www.' in u:
        usplit = u.split('://www')
        u = usplit[1]
    if '/' in u:
        usplit = u.split('/')
        u = usplit[0]
    usplit = u.split('.')
    if len(usplit) > 1:
        if usplit[len(usplit) - 2] == 'co':
            dom = usplit[len(usplit) - 3] + '.' + usplit[len(usplit) - 2] + '.' + usplit[len(usplit) - 1]
        else:
            dom = usplit[len(usplit) - 2] + '.' + usplit[len(usplit) - 1]
    else:
        dom = ''

    if '?' in dom:
        domsplit = dom.split('?')
        dom = domsplit[0]

    return dom.lower()

def get_red(r):

    if 'http' not in r:
        r2 = 'http://' + r
    else:
        r2 = r

    m_chain = getListOfRedirectUrls(r2, 2)
    if m_chain:
        return m_chain

    else:
        return [r]

def get_shorturls():

    with open('config.json') as fp:
        raw_data = json.load(fp)


    db = pymysql.connect(
        user=raw_data['db']['username'],password=raw_data['db']['password'],
        db=raw_data['db']['spam_portal_db'],host=raw_data['db']['host'],
        port=int(raw_data['db']['port']), cursorclass=pymysql.cursors.DictCursor)
    db.autocommit = True
    cursor = db.cursor()
    cursor.execute('SELECT domain from pylon_domain WHERE is_shortener = 1 LIMIT 100000000;')
    result = cursor.fetchall()

    short_urls = []
    #print result
    for res in result:
        short_urls.append(res['domain'])

    cursor.close()
    db.close()

    return short_urls


def get_attack_structure(text):
    phos, emails, urls = get_ctas(text)

    url_dict = {}
    url_dom_dict = {}

    if urls:
        short_urls = get_shorturls()

    #print 'sr', short_urls

    lp_doms = []
    for u in urls:
        red_list = get_red(u)
        final_u = str(red_list[len(red_list) - 1])
        #print red_list
        #print str(red_list[len(red_list) - 1])
        #print short_urls
        #print get_dom(str(red_list[len(red_list) - 1]))
        if get_dom(str(red_list[len(red_list) - 1])) in short_urls:
            lp_doms.append(u)
            final_u = u
        else:
            lp_doms.append(get_dom(str(red_list[len(red_list) - 1])))
        url_dict[u] = red_list
        lp_dom = get_dom(str(red_list[len(red_list) - 1]))
        url_dom_dict[u] = lp_dom
        if lp_dom not in url_dom_dict:
            url_dom_dict[lp_dom] = lp_dom
            url_dict[lp_dom] = [lp_dom]

    cta = []
    if len(phos) > 0:
        cta = cta + phos
    if len(emails) > 0:
        cta = cta + emails
    if len(lp_doms) > 0:
        cta = cta + lp_doms

    if cta:
        cta = str(','.join(cta))
    else:
        cta = 'NA'

    return cta, phos, emails, url_dict, url_dom_dict
