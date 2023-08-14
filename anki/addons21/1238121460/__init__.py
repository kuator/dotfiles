import anki
import aqt
from aqt import mw
from datetime import datetime
from anki.hooks import addHook, wrap
from aqt.deckbrowser import DeckBrowser


def generateStats():
	time = mw.col.db.first("""select sum(time) from revlog""")
	ttime = time if time != None else 0
	
	if ttime == 0:
		string = f"<br/>No time spent reviewing yet."
	else:	
		ttime = str(int(str(ttime).replace("(","").replace("[","").replace("]","").replace(")","").replace(",","").replace("None","0")))
		ttime = int(ttime)/(3600000)
		string = f"<br/>{ttime:,.2f} total hours spent reviewing."

	return string

def renderStats(self, _old):
	return _old(self) + generateStats()

def db_wrc(deck_browser, content):
	content.stats += generateStats()


### code taken from somebody else (who?)
# for some reason it works offline, but not when adding it via ankiweb(order in which the plugin loads, probably)
# honestly no clue what this does but it fixes this problem, thanks glutanimate??
try:
	from aqt.gui_hooks import deck_browser_will_render_content
	deck_browser_will_render_content.append(db_wrc)
except (ImportError, ModuleNotFoundError):
	DeckBrowser._renderStats = wrap(DeckBrowser._renderStats, renderStats, 'around')

