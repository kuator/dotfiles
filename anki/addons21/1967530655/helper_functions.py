from collections import OrderedDict
import datetime
import io
import os
import time

from anki.utils import pointVersion
from aqt import mw
from aqt.utils import showInfo
from aqt.qt import *


from .config import anki_21_version, gc


def due_day(card):
    if card.queue <= 0:
        return ""
    else:
        if card.queue in (2, 3):
            if card.odue:
                myvalue = card.odue
            else:
                myvalue = card.due
            mydue = time.time()+((myvalue - mw.col.sched.today)*86400)
        else:
            if card.odue:
                mydue = card.odue
            else:
                mydue = card.due
        return time.strftime("%Y-%m-%d", time.localtime(mydue))


def valueForOverdue(card):
    # old code in this add-on
    if anki_21_version <= 44:
        return mw.col.sched._daysLate(card)
    else:
        # from my sidebar add-on
        myvalue = 0
        if card.queue in (0, 1) or card.type == 0:
            myvalue = 0
        elif card.odue and (card.queue in (2, 3) or (type == 2 and card.queue < 0)):
            myvalue = card.odue
        elif card.queue in (2, 3) or (card.type == 2 and card.queue < 0):
            myvalue = card.due
        if myvalue:
            diff = myvalue - mw.col.sched.today
            if diff < 0:
                a = diff * - 1
                return max(0, a)
            else:
                return 0
        else:
            return 0


def percent_overdue(card):
    overdue = valueForOverdue(card)
    ivl = card.ivl
    if ivl > 0:
        return "{0:.2f}".format((overdue+ivl)/ivl*100)


def fmt_long_string(name, value):
    l = 0
    u = value
    out = ""
    while l < len(name):
        out += name[l:l+u] + '\n'
        l += u
    return out.rstrip('\n')


def allRevsForCard(cid):
    entries = mw.col.db.all(
        "select id/1000.0, ease, ivl, factor, time/1000.0, type "
        "from revlog where cid = ?", cid)
    if not entries:
        return ""
    allRevs = ""
    for (date, ease, ivl, factor, taken, type) in entries:
        tstr = ["Lrn", "Rev", "ReLn", "Filt", "Resch"][type]
            # Learned, Review, Relearned, Filtered, Defered (Rescheduled)
        int_due = "na"
        if ivl > 0:
            int_due_date = time.localtime(date + (ivl * 24 * 60 * 60))
            int_due = time.strftime("%Y-%m-%d", int_due_date)
        allRevs += "#".join((time.strftime("%Y-%m-%dT@%H:%M", time.localtime(date)), 
                             str(tstr),
                             str(ease),
                             str(ivl),
                             str(int_due),
                             str(int(factor / 10)) if factor else "")) + '-----'
    return allRevs


def getSaveDir(parent, title, identifier_for_last_user_selection):
    config_key = identifier_for_last_user_selection + 'Directory'
    defaultPath = QStandardPaths.writableLocation(QStandardPaths.DocumentsLocation)
    path = mw.pm.profile.get(config_key, defaultPath)
    dir = QFileDialog.getExistingDirectory(parent, title, path, QFileDialog.ShowDirsOnly)
    return dir


def now():    #time
    CurrentDT=datetime.datetime.now()
    return CurrentDT.strftime("%Y-%m-%dT%H-%M-%S")


def timespan(t):
    """for change from https://github.com/ankitects/anki/commit/89dde3aeb0c1f94b912b3cb2659ec0d4bffb4a1c"""
    if pointVersion() < 28:
        return mw.col.backend.format_time_span(t)
    else:
        return mw.col.format_timespan(t)
