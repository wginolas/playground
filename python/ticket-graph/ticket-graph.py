from redmine import Redmine
import urllib
import json
import dateutil.parser
from pylab import *
import matplotlib
import itertools

BUG = 1
FEATURE = 2
SUPPORT = 3

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


def is_sammel_ticket(issue):
    for c in issue["issue"]["custom_fields"]:
        if c["name"] == "Sammel-Ticket":
            return c.get("value", "0") == '1'
    return False


def analyse_journal(issue):
    if is_sammel_ticket(issue):
        return []
    issue_created_on = dateutil.parser.parse(issue["issue"]["created_on"])
    first_status = issue["issue"]["status"]["id"]
    first = True
    result = [None]
    for j in issue["issue"]["journals"]:
        created_on = dateutil.parser.parse(j["created_on"])
        for d in j["details"]:
            if d["property"] == "attr" and d["name"] == "status_id":
                if first:
                    first_status = d["old_value"]
                    first = False
                result.append((created_on, d["new_value"] not in CLOSED_STATUS, issue["issue"]["id"]))
    result[0] = (issue_created_on, str(first_status) not in CLOSED_STATUS, issue["issue"]["id"])
    return result


def reduce_journal(journal):
    last_open = False
    count = 0
    for (t, o, i) in journal:
        if last_open != o:
            d = 1 if o else -1
            count += d
            yield (t, d)
            last_open = o


def sum_journal(diffs):
    count = 0
    for (t, d) in diffs:
        count += d
        yield (t, count)
    #yield (datetime.datetime.utcnow(), count)

    
def filter_by_time(data):
    end = data[-1][0]
    start = end - datetime.timedelta(days=60)
    print "start: %s, end: %s" % (start, end)
    print "start: %s, end: %s" % (type(start), type(end))
    return filter(lambda x: x[0] >= start and x[0] <= end, data)

    
def plot_tickets(tracker_id, fname):
    with open("/home/wolfgang/keys/redmine.key") as f:
        key = f.read().strip()

    instance = Redmine("https://redmine.justsoftwareag.com", key = key)
    raw_issues = list(instance.projects["jc"].issues(tracker_id=tracker_id, status_id="*"))
    issues = list(load_tickets(raw_issues, key))

    data = [reduce_journal(analyse_journal(i)) for i in issues]
    data = itertools.chain.from_iterable(data)
    data = sorted(data, key=lambda x: x[0])
    data = list(sum_journal(data))

    subplot(2, 1, 1)
    x1, y1 = zip(*data)
    step(x1, y1, where="post")

    subplot(2, 1, 2)
    print data
    current_data = filter_by_time(data)
    print current_data
    x2, y2 = zip(*current_data)
    step(x2, y2, where="post")

    savefig(fname)


def main():
    matplotlib.rc("font", size=8)
    plot_tickets(SUPPORT, "support.png")
    plot_tickets(BUG, "bug.png")

main()

