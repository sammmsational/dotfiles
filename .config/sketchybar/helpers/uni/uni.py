import datetime as dt
import logging
import pickle
import sys
import tomllib
from base64 import b64decode
from pathlib import Path
from zoneinfo import ZoneInfo

import requests
from caldav.davclient import get_davclient
from caldav.lib.error import DAVError
from icalendar import Calendar
from requests import HTTPError

# create logger
l = logging.getLogger(__name__)
logFormatter = logging.Formatter(
    fmt="%(asctime)s :: %(levelname)s :: %(message)s",
    datefmt="%y-%m-%d %H:%M:%S",
)
handler = logging.StreamHandler(stream=sys.stderr)
handler.setFormatter(logFormatter)
handler.setLevel(logging.DEBUG)
l.addHandler(handler)
l.setLevel(logging.INFO)

scriptdir = Path(__file__).parent
efile_path = Path(scriptdir / "events.pkl")
if l.level == 10:
    now = dt.datetime(
        2025, 11, 19, 17, 30, tzinfo=ZoneInfo("Europe/Berlin")
    )  # MANUALLY SET CURRENT DATE FOR DEBUGGING
else:
    now = dt.datetime.now().astimezone()

try:
    with Path(scriptdir / "credentials.toml").open("rb") as f:
        credentials = tomllib.load(f)
    l.info("Credfile loaded")
except IOError as ioe:
    l.warning(ioe)
    credentials = {}
try:
    with Path(scriptdir / "courses.toml").open("rb") as f:
        courses = tomllib.load(f)
    l.info("Courses loaded")
except IOError as ioe:
    l.error(ioe)
    courses = {}


def course_lookup(lookup: dict, req: str = "code", fallback="summary"):
    for _, x in courses.items():
        if x["title"] == lookup["SUMMARY"]:
            try:
                return x[req]
            except KeyError:
                return lookup[req]
    return lookup[fallback]


def load_from_file(filepath: Path, cal_in: Calendar = Calendar()):
    try:
        with filepath.open("rb") as f:
            loaded_cal: Calendar = pickle.load(f)
            for e in loaded_cal.events:
                cal_in.add_component(e)
        l.info(
            f"Event data loaded from file (mod: "
            f"{dt.datetime.fromtimestamp(efile_path.lstat().st_mtime).strftime('%d.%m.%y %H:%M')})"
        )
    except IOError as ioe:
        l.error(ioe)
    return cal_in


def save_to_file(cal_in: Calendar):
    try:
        with efile_path.open("wb") as f:
            pickle.dump(cal_in, f)
        l.info("Event data saved to file")
    except IOError as ioe:
        l.warning(ioe)


def load_from_dav(
    credentials: dict,
    cal_in: Calendar = Calendar(),
):
    try:
        with get_davclient(
            username=credentials["username"],
            password=b64decode(credentials["password"]),
            url=credentials["url"],
        ) as client:
            my_principal = client.principal()
            result_cal = my_principal.calendar(name=credentials["calname"])
            for e in result_cal.events():
                cal_in.add_component(e.icalendar_component)
        l.info("Event data loaded from dav")
    except DAVError as dave:
        l.error(dave)
    return cal_in


def load_from_web(url: str, cal_in: Calendar = Calendar()):
    try:
        r = requests.get(url)
        r.raise_for_status()
        rcal = Calendar.from_ical(r.text)
        for e in rcal.walk("VEVENT"):
            cal_in.add_component(e)
        l.info("Event data loaded from calendar url")
    except HTTPError as httpe:
        l.error(httpe)
    return cal_in


def format_td(td_in: dt.timedelta, min_only: bool = False):
    tds = int(td_in.total_seconds())
    hours = tds // 3600
    minutes = (tds - hours * 3600) // 60
    if hours == 1 and minutes <= 30:
        return f"{hours * 60 + minutes} min"
    elif hours != 0:
        return f"{hours}:{minutes:02d}h"
    elif min_only:
        return f"{(hours * 60 + minutes):02d} min"
    else:
        return f"{minutes} min"


def load_from_credentials(creds_in: dict):
    l.info("Loading calendar data from web wtih credentials")
    cal = Calendar()
    for x in creds_in:
        if creds_in[x]["type"] == "web":
            cal = load_from_web(creds_in[x]["url"], cal)
        elif creds_in[x]["type"] == "dav":
            cal = load_from_dav(creds_in[x], cal)
    return cal


def main():
    if l.level == 10:
        cal = load_from_credentials(credentials)
    elif (
        efile_path.is_file()
        and (
            now
            - dt.datetime.fromtimestamp(
                efile_path.lstat().st_mtime, tz=ZoneInfo("Europe/Berlin")
            )
        ).total_seconds()
        < 3600
    ):
        cal = load_from_file(efile_path)
    else:
        cal = load_from_credentials(credentials)
        save_to_file(cal)

    e_list = []
    for e in cal.events:
        if (
            isinstance(e.start, dt.datetime)  # sorts out all-day events
            and e.start.date() == now.date()
            and e.end > now
        ):
            e_list.append(e)
    e_list.sort(key=lambda x: x.start)
    for x in e_list:
        l.debug(type(x))
        l.debug(x["summary"])
        l.debug(x.start)
        l.debug(x["location"])

    if len(e_list) == 0:
        return f"0"  # case 0: no events
    else:
        e = e_list[0]
    if e.start >= now:  # case 1: before an event
        return (
            f"1"
            f"\n{course_lookup(e, "short", "summary")}"
            f"\nin "
            f"\n{format_td(e.start - now)}"
            f"\n—"
            f"\n{course_lookup(e, "location", "location")}"
        )
    elif e.start < now and len(e_list) > 1:  # case 2: during not last event
        return (
            f"2"
            f"\n{course_lookup(e, "code", "summary")}"
            f"\n—"
            f"\n{format_td(e.end - now, True)}"
            f"\n|"
            f"\n{format_td(e_list[1].start - e.end)}"
            f"\nPause |"
            f"\n{course_lookup(e_list[1], "short", "summary")}"
            f"\n—"
            f"\n{course_lookup(e_list[1], "location", "location")}"
        )
    elif e.start < now and len(e_list) == 1:  # case 3 during last event
        return (
            f"3"
            f"\n{course_lookup(e, "short", "summary")}"
            f"\n—"
            f"\n{format_td(e.end - now)}"
        )

    l.warning("No cases caught")
    return 1


if __name__ == "__main__":
    print(main())
