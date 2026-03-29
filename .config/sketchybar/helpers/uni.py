import datetime as dt
import logging
import pickle
import sys
import tomllib
from base64 import b64decode
from pathlib import Path
from zoneinfo import ZoneInfo

import icalendar as ical
import requests
from caldav.davclient import get_davclient
from caldav.lib.error import DAVError
from requests import HTTPError, RequestException

SCRIPT_DIR = Path(__file__).parent
EVENTS_PKL = Path(SCRIPT_DIR / "events.pkl")
try:
    EVENTS_PKL_MODDATE = dt.datetime.fromtimestamp(
        EVENTS_PKL.stat().st_mtime, tz=ZoneInfo("Europe/Berlin")
    )
except FileNotFoundError as fne:
    EVENTS_PKL_MODDATE = None
COURSES_TOML = Path(SCRIPT_DIR / "courses.toml")
CREDENTIALS_TOML = Path(SCRIPT_DIR / "credentials.toml")
DEBUG_FUNC = False
DEBUG_LOG = False


l = logging.getLogger(__name__)
logFormatter = logging.Formatter(
    fmt="%(asctime)s :: %(levelname)s :: %(message)s",
    datefmt="%y-%m-%d %H:%M:%S",
)
handler = logging.StreamHandler(stream=sys.stderr)
handler.setFormatter(logFormatter)
handler.setLevel(logging.DEBUG)
l.addHandler(handler)
l.setLevel(logging.DEBUG) if DEBUG_LOG else l.setLevel(logging.INFO)

if DEBUG_FUNC:
    now = dt.datetime(2025, 12, 8, 9, 30, tzinfo=ZoneInfo("Europe/Berlin"))
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
        courses: dict[str, dict[str, str]] = tomllib.load(f)
    l.info("Courses loaded")
except IOError as ioe:
    l.error(ioe)
    courses: dict[str, dict[str, str]] = {}


class NoDataError(IOError):
    pass


class Event:
    start: dt.datetime
    end: dt.datetime
    _key: str
    location: str
    title: str
    short: str
    code: str
    url: str

    def __init__(self, e: ical.Event):
        if isinstance(e.start, dt.datetime):
            self.start = e.start
        else:
            raise TypeError
        if isinstance(e.end, dt.datetime):
            self.end = e.end
        else:
            raise TypeError
        self._key = ""
        for k, v in courses.items():
            if e["summary"] == v["title"]:
                self._key = k
        try:
            self.location = courses[self._key]["location"]
        except KeyError:
            try:
                self.location = e["location"]
            except KeyError:
                self.location = "NOLOC"

        try:
            self.title = courses[self._key]["title"]
        except KeyError:
            try:
                self.title = e["summary"]
            except KeyError:
                self.title = "NOTITLE"

        try:
            self.short = courses[self._key]["short"]
        except KeyError:
            self.short = (self.title[:15] + "…") if len(self.title) > 15 else self.title

        try:
            self.code = courses[self._key]["code"]
        except KeyError:
            self.code = (self.title[:5] + "…") if len(self.title) > 5 else self.title

        try:
            self.url = courses[self._key]["url"]
        except KeyError:
            try:
                self.url = e["url"]
            except KeyError:
                self.url = "https://moodle.thm.de/my/courses.php"

        if not all(
            (
                self.start,
                self.end,
                self.location,
                self.title,
                self.short,
                self.code,
                self.url,
            )
        ):
            raise ValueError


def load_from_file() -> list[Event]:
    with EVENTS_PKL.open("rb") as f:
        data = pickle.load(f)
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


def load_from_dav() -> list[ical.Event]:
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


def load_from_web() -> list[ical.Event]:
    events = []
    for name, entry in credentials.items():
        if entry["type"] == "web":
            try:
                r = requests.get(entry["url"])
                r.raise_for_status()
                rcal = ical.Calendar.from_ical(r.text)
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


def td_fmt(td: dt.timedelta) -> str:
    seconds = int(td.total_seconds())
    hours, seconds = divmod(seconds, 3600)
    minutes, seconds = divmod(seconds, 60)

    if not hours:
        if not seconds:
            fmt = f"{minutes:02d} min"
        else:
            fmt = f"{(minutes+1):02d} min"
    elif minutes == 60:
        fmt = "60 min"
    else:
        fmt = f"{hours:02d}:{minutes:02d}h"

    return fmt


def main() -> str:
    ical_events = []
    events = []
    if DEBUG_FUNC:
        [ical_events.append(e) for e in load_from_web()]
        [ical_events.append(e) for e in load_from_dav()]
    else:
        if not EVENTS_PKL_MODDATE or (now - EVENTS_PKL_MODDATE).total_seconds() > 3600:
            try:
                [ical_events.append(e) for e in load_from_web()]
                [ical_events.append(e) for e in load_from_dav()]
            except RequestException as e:
                l.warning(e)
        else:
            events = load_from_file()

    if not events:
        for e in ical_events:
            if (
                isinstance(e.start, dt.datetime)  # is not an all-day event
                and e.start.date() == now.date()  # is today
                and e.end > now  # has not ended
            ):
                events.append(Event(e))
        save_to_file(events)
    else:  # remove old events
        for i, e in enumerate(events):
            if e.end < now:
                events.pop(i)

    events.sort(key=lambda e: e.start)

    l.info(f"{len(events)} events loaded")

    if not events:
        return "0"  # no events
    else:
        e = events[0]
    if e.start >= now:  # before an event
        return f"{e.url}\n" + " ".join(
            [
                e.short,
                "in",
                td_fmt(e.start - now),
                "—",
                e.location,
            ]
        )
    elif e.start < now and len(events) > 1:  # during not last event
        return f"{e.url}\n" + " ".join(
            [
                e.code,
                "—",
                td_fmt(e.end - now),
                "╏",
                td_fmt(events[1].start - e.end),
                "Pause ╏",
                events[1].short,
                "—",
                events[1].location,
            ]
        )
    elif e.start < now and len(events) == 1:  # during last event
        return f"{e.url}\n" + " ".join([e.short, "—", td_fmt(e.end - now)])
    return "PYERR"


if __name__ == "__main__":
    print(main(), end="")
