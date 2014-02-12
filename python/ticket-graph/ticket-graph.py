import json
import dateutil.parser
import pylab
import datetime
import matplotlib
import itertools
import sqlite3

BUG = 1
FEATURE = 2
SUPPORT = 3

CLOSED_STATUS = {"3", "5", "6"}

PRIO_MAP = {
    "3": "LOW",
    "4": "NORMAL",
    "5": "HIGH"
}

PRIOS = ["HIGH", "NORMAL", "LOW"]
COLORS = ["#ff0000", "#ffff00", "#00ff00"]

def internal_prio(redmine_prio_id):
    if redmine_prio_id is None:
        return None
    else:
        return PRIO_MAP.get(str(redmine_prio_id), "HIGH")


def is_sammel_ticket(issue):
    for c in issue["custom_fields"]:
        if c["name"] == "Sammel-Ticket":
            return c.get("value", "0") == '1'
    return False


def journal_row(created_on, status_id, prio_id, issue_id):
    open_prio = str(prio_id)
    if str(status_id) in CLOSED_STATUS:
        open_prio = None
    return (
        created_on,
        open_prio,
        issue_id
    )


def find_first_in_journal(journal, attr_name, default):
    for j in journal:
        for d in j["details"]:
            if d["property"] == "attr" and d["name"] == attr_name:
                return d["old_value"]
    return default


def analyse_journal(issue):
    if is_sammel_ticket(issue):
        return []
    issue_created_on = dateutil.parser.parse(issue["created_on"])
    current_status = find_first_in_journal(
        issue["journals"],
        "status_id",
        str(issue["status"]["id"]))
    current_prio = find_first_in_journal(
        issue["journals"],
        "priority_id",
        str(issue["priority"]["id"]))
    result = [journal_row(
        issue_created_on,
        current_status,
        current_prio,
        issue["id"])]
    for j in issue["journals"]:
        created_on = dateutil.parser.parse(j["created_on"])
        for d in j["details"]:
            if d["property"] == "attr" and d["name"] == "priority_id":
                current_prio = d["new_value"]
            if d["property"] == "attr" and d["name"] == "status_id":
                current_status = d["new_value"]
            result.append(journal_row(
                created_on,
                current_status,
                current_prio,
                issue["id"]))
    return result


def reduce_journal(journal):
    last_prio = None
    for (t, prio, i) in journal:
        ip = internal_prio(prio)
        if last_prio != ip:
            if last_prio is not None:
                yield (t, last_prio, -1)
            if ip is not None:
                yield (t, ip, 1)
            last_prio = ip


def sum_journal(diffs):
    count = {}
    for p in PRIOS:
        count[p] = 0
    for (t, prio, d) in diffs:
        yield (t, count.copy())
        count[prio] = count[prio] + d
        yield (t, count.copy())
    #yield (datetime.datetime.utcnow(), count)


def filter_by_time(data, tdelta):
    end = data[-1][0]
    start = end - tdelta
    print "start: %s, end: %s" % (start, end)
    print "start: %s, end: %s" % (type(start), type(end))
    return filter(lambda x: x[0] >= start and x[0] <= end, data)


def split_sum(s):
    t, m = s
    return (t, [m[p] for p in PRIOS])


def plot_tickets(tracker_name, db_name, image_name):
    conn = sqlite3.connect(db_name)
    cur = conn.cursor()

    rows = cur.execute("select json from tickets")
    all_issues = (json.loads(r[0]) for r in rows)
    issues = [i for i in all_issues if i["tracker"]["name"] == tracker_name]
    cur.close()
    conn.close()

    data = [reduce_journal(analyse_journal(i)) for i in issues]
    data = itertools.chain.from_iterable(data)
    data = sorted(data, key=lambda x: x[0])
    data = [split_sum(d) for d in sum_journal(data)]

    pylab.figure(figsize=(9, 10))
    pylab.subplot(2, 1, 1)
    pylab.title(tracker_name)
    x1, y1 = zip(*data)
    y1 = zip(*y1)
    pylab.grid()
    pylab.stackplot(x1, y1, colors=COLORS)
    high = pylab.Rectangle((0, 0), 1, 1, fc=COLORS[0])
    normal = pylab.Rectangle((0, 0), 1, 1, fc=COLORS[1])
    low = pylab.Rectangle((0, 0), 1, 1, fc=COLORS[2])
    pylab.legend([low, normal, high], ["Low", "Normal", "High"], loc=2)

    pylab.subplot(2, 1, 2)
    pylab.title(tracker_name + " (Die letzen 5 Wochen)")
    current_data = filter_by_time(data, datetime.timedelta(days=45))
    x2, y2 = zip(*current_data)
    y2 = zip(*y2)
    pylab.grid()
    pylab.stackplot(x2, y2, colors=COLORS)

    pylab.savefig(image_name)


def main():
    matplotlib.rc("font", size=8)
    plot_tickets("Support", "tickets.db", "support.png")
    plot_tickets("Bug", "tickets.db", "bug.png")
#    plot_tickets("Feature", "tickets.db", "feature.png")
#    plot_tickets("Feature-Request", "tickets.db", "feature-request.png")

main()
