from aqt import mw
from aqt.utils import showInfo
from aqt.qt import *


def remDupes():
    counter = 0
    mw.window().checkpoint(_("Delete Note Types"))
    for model in mw.col.models.all():
        if mw.col.models.useCount(model) == 0:
            counter += 1
            mw.col.models.rem(model)
    mw.window().requireReset()
    showInfo("%d empty note types deleted." %counter)

action = QAction("Remove Empty Note Types", mw)
action.triggered.connect(remDupes)
mw.form.menuTools.addAction(action)
