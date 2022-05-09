# Copyright: Ren Tatsumoto <tatsu at autistici.org>
# License: GNU AGPL, version 3 or later; http://www.gnu.org/licenses/agpl.html

from typing import NewType

EasePercent = NewType("EasePercent", int)

ADDON_NAME = "Refold Ease"
RUN_BUTTON_TEXT = "Run"
MIN_EASE = EasePercent(131)
MAX_EASE = EasePercent(1000)
ANKI_DEFAULT_EASE = EasePercent(250)
ANKI_SETUP_GUIDE = 'https://tatsumoto.neocities.org/blog/setting-up-anki.html'
