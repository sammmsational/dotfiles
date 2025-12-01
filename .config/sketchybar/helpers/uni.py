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
from icalendar import Calendar, Event
from requests import HTTPError

SCRIPT_DIR = Path(__file__).parent
EVENTS_PKL = Path(SCRIPT_DIR / "events.pkl")
COURSES_TOML = Path(SCRIPT_DIR / "courses.toml")
CREDENTIALS_TOML = Path(SCRIPT_DIR / "credentials.toml")
# if DEBUG == True, manually set date is used and events are always loaded from credentials
DEBUG = True


class NoDataError(IOError):
    pass


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
l.setLevel(logging.DEBUG) if DEBUG else l.setLevel(logging.INFO)

if DEBUG:
    now = dt.datetime(
        2025, 12, 8, 9, 30, tzinfo=ZoneInfo("Europe/Berlin")
    )  # MANUALLY SET CURRENT DATE FOR DEBUGGING
else:
    now = dt.datetime.now().astimezone()

try:
    with CREDENTIALS_TOML.open("rb") as f:
        credentials = tomllib.load(f)
    l.info("Credfile loaded")
except IOError as ioe:
    l.error(ioe)
    credentials = {}
try:
    with COURSES_TOML.open("rb") as f:
        courses = tomllib.load(f)
    l.info("Courses loaded")
except IOError as ioe:
    l.error(ioe)
    courses = {}


def load_from_file() -> list[Event]:
    # error handling is done when function is called to avoid recursion
    with EVENTS_PKL.open("rb") as f:
        data: list[Event] = pickle.load(f)
        l.info(
            f"Data loaded from file (last mod: "
            f"{dt.datetime.fromtimestamp(EVENTS_PKL.lstat().st_mtime).strftime('%d.%m.%y %H:%M')})"
        )
        return data


def save_to_file(data: list[Event]) -> None:
    try:
        with EVENTS_PKL.open("wb") as f:
            pickle.dump(data, f)
        l.info("Data saved to file")
    except IOError as ioe:
        l.warning("Could not save data to file")
        l.warning(ioe)


def load_from_dav() -> list[Event]:
    events = []
    for name, entry in credentials.items():
        if entry["type"] == "dav":
            try:
                with get_davclient(
                    username=entry["username"],
                    password=b64decode(entry["password"]),
                    url=entry["url"],
                ) as client:
                    my_principal = client.principal()
                    result_cal = my_principal.calendar(name=entry["calname"])
                    for e in result_cal.events():
                        events.append(e.icalendar_component)
                l.info(f"Events loaded from '{name}'")
            except DAVError as dave:
                l.warning(f"Events could not be loaded from '{name}'")
                l.warning(dave)
    if events:
        return events
    else:
        raise NoDataError


def load_from_web() -> list[Event]:
    events = []
    for name, entry in credentials.items():
        if entry["type"] == "web":
            try:
                r = requests.get(entry["url"])
                r.raise_for_status()
                rcal = Calendar.from_ical(r.text)
                for e in rcal.walk("VEVENT"):
                    events.append(e)
                l.info(f"Events loaded from '{name}'")
            except HTTPError as httpe:
                l.warning(f"Could not load events from '{name}'")
                l.warning(httpe)
    if events:
        return events
    else:
        raise NoDataError


def format_td(td_in: dt.timedelta, min_only: bool = False) -> str:
    tds = int(td_in.total_seconds())
    hours = tds // 3600
    minutes = (tds - hours * 3600) // 60 + 1
    if hours == 1 and minutes <= 30:
        return f"{hours * 60 + minutes} min"
    elif hours != 0:
        return f"{hours}:{minutes:02d}h"
    elif min_only:
        return f"{(hours * 60 + minutes):02d} min"
    else:
        return f"{minutes} min"


def course_lookup(lookup: dict, req: str = "code", fallback="summary") -> str:
    for _, x in courses.items():
        if x["title"] == lookup["SUMMARY"]:
            try:
                return x[req]
            except KeyError:
                return lookup[req]
    return lookup[fallback]


def main() -> str:
    all_events = []
    if (
        DEBUG
        or (
            now
            - dt.datetime.fromtimestamp(
                EVENTS_PKL.lstat().st_mtime, tz=ZoneInfo("Europe/Berlin")
            )
        ).total_seconds()
        < 3600
    ):
        try:
            [all_events.append(e) for e in load_from_web()]
            [all_events.append(e) for e in load_from_dav()]
            save_to_file(all_events)
        except NoDataError:
            l.error("No data from web or dav, falling back to file")
            try:
                [all_events.append(e) for e in load_from_file()]
            except IOError:
                l.error("Unable to load any data. Exiting...")
                return "0"

    else:
        try:
            [all_events.append(e) for e in load_from_file()]
        except IOError as ioe:
            l.error("Unable to load data from file, falling back to credentials")
            l.error(ioe)
            try:
                [all_events.append(e) for e in load_from_web()]
                [all_events.append(e) for e in load_from_dav()]
                save_to_file(all_events)
            except NoDataError:
                l.error("Unable to load any data. Exiting...")
                return "0"

    l.debug(f"{len(all_events)} events loaded")

    events = []
    for e in all_events:
        if (
            isinstance(e.start, dt.datetime)  # is not an all-day event
            and e.start.date() == now.date()  # is today
            and e.end > now  # has not ended
        ):
            events.append(e)
    events.sort(key=lambda x: x.start)

    if not events:
        return "0"  # case 1: no events
    else:
        e = events[0]
    if e.start >= now:  # case 2: before an event
        return " ".join(
            [
                course_lookup(e, "short", "summary"),
                "in",
                format_td(e.start - now),
                "—",
                course_lookup(e, "location", "location"),
            ]
        )
    elif e.start < now and len(events) > 1:  # case 3: during not last event
        return " ".join(
            [
                course_lookup(e, "code", "summary"),
                "—",
                format_td(e.end - now, True),
                "╏",
                format_td(events[1].start - e.end),
                "Pause ╏",
                course_lookup(events[1], "short", "summary"),
                "—",
                course_lookup(events[1], "location", "location"),
            ]
        )
    elif e.start < now and len(events) == 1:  # case 4 during last event
        return " ".join(
            [course_lookup(e, "short", "summary"), "—", format_td(e.end - now)]
        )
    return "PYERR"


if __name__ == "__main__":
    print(main(), end="")
