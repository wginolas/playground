from redmine import Redmine
import urllib
import json
import dateutil.parser
import itertools
import sqlite3
import os.path

BUG = 1
FEATURE = 2
SUPPORT = 3
FEATURE_REQUEST = 4

CLOSED_STATUS = {"3", "5", "6"}


def load_ticket(ticket_id, key):
    url = ("https://redmine.justsoftwareag.com/issues/%s.json?" % ticket_id) + urllib.urlencode({
        "key": key,
        "include": "journals"
    })
    print url
    s = urllib.urlopen(url).read()
    return json.loads(s)


def load_tickets(raw_issues, key):
    for i in raw_issues:
        yield load_ticket(i.id, key)


def create_db(fname):
    conn = sqlite3.connect(fname)
    cur = conn.cursor()

    cur.execute("create table tickets(id, json)");
    cur.close()
    return conn
    
def download_tickets(tracker_id, conn):
    cur = conn.cursor()

    with open(os.path.expanduser("~/keys/redmine.key")) as f:
        key = f.read().strip()

    instance = Redmine("https://redmine.justsoftwareag.com", key = key)
    raw_issues = instance.projects["jc"].issues(tracker_id=tracker_id, status_id="*")
    issues = load_tickets(raw_issues, key)

    for i in issues:
        #print json.dumps(i)
        ticket_id = i["issue"]["id"]
        print ticket_id
        cur.execute("insert into tickets(id, json) values (?, ?)", (ticket_id, json.dumps(i["issue"])))


def main():
    conn = create_db("tickets.db")
    download_tickets(SUPPORT, conn)
    download_tickets(BUG, conn)
#    download_tickets(FEATURE_REQUEST, conn)
#    download_tickets(FEATURE, conn)
    conn.commit()
    conn.close()

main()
