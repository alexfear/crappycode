import urllib
import urllib2
import ssl
import json

url = "https://nsx/api/4.0/edges"
req = urllib2.Request(url)
req.add_header('Authorization','Basic ')
req.add_header('Content-Type','application/json')
req.add_header('Accept','application/json')
resp = urllib2.urlopen(req, context=ssl._create_unverified_context())
content = json.load(resp)
print content
