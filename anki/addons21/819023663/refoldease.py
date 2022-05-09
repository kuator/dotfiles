# Copyright: Ren Tatsumoto <tatsu at autistici.org>
# License: GNU AGPL, version 3 or later; http://www.gnu.org/licenses/agpl.html

import math
from typing import List, Tuple, Callable, Iterable, Dict, Any

from anki.cards import Card
from aqt import mw
from aqt.qt import QObject, pyqtSignal, qconnect
from aqt.utils import showInfo

from .config import config
from .consts import *


######################################################################
# Reset ease & other utils
######################################################################

def whole_collection_id() -> int:
    return -1


def maybe_sync_before():
    # sync before resetting ease, if enabled
    if config.get('sync_before_reset') is True:
        mw.on_sync_button_clicked()


def maybe_sync_after():
    # force a one-way sync if enabled
    if config.get('force_sync_in_one_direction') is True:
        mw.col.mod_schema(check=False)

    # sync after resetting ease if enabled
    if config.get('sync_after_reset') is True:
        mw.on_sync_button_clicked()


def form_msg() -> str:
    msg: List[str] = ["Ease has been reset to {}%."]

    if config.get('sync_after_reset'):
        msg.append("\nCollection will be synchronized")
        if config.get('force_sync_in_one_direction'):
            msg.append("in one direction.")
        else:
            msg.append(".")

    msg.append("\nDon't forget to check your Interval Modifier and Starting Ease.")

    return ''.join(msg)


def maybe_notify_done(ez_factor_human: int):
    if config.get('show_reset_notification'):
        showInfo(form_msg().format(ez_factor_human))


def whole_col_selected(dids: List[int]) -> bool:
    return len(dids) == 1 and dids[0] == whole_collection_id()


def reset_ease_db(dids: List[int], factor_anki: int):
    if whole_col_selected(dids):
        mw.col.db.execute("update cards set factor = ?", factor_anki)
    else:
        for did in dids:
            mw.col.db.execute("update cards set factor = ? where did = ?", factor_anki, did)


def get_cards_by_dids(dids: List[int]) -> Iterable[Card]:
    if whole_col_selected(dids):
        card_ids = mw.col.db.list("SELECT id FROM cards WHERE factor != 0")
    else:
        card_ids = set()
        for did in dids:
            card_ids.update(mw.col.db.list("SELECT id FROM cards WHERE factor != 0 AND did = ?", did))

    return (mw.col.get_card(card_id) for card_id in card_ids)


def reset_ease_col(dids: List[int], factor_anki: int):
    for card in get_cards_by_dids(dids):
        if card.factor != factor_anki:
            card.factor = factor_anki
            card.flush()


def reset_ease(dids: List[int], factor_human: int) -> None:
    if config.get('modify_db_directly') is True:
        reset_ease_db(dids, ez_factor_anki(factor_human))
    else:
        reset_ease_col(dids, ez_factor_anki(factor_human))


def ez_factor_anki(ez_factor_human: int) -> int:
    return int(ez_factor_human * 10)


def ivl_factor_anki(ivl_fct_human: int) -> float:
    return float(ivl_fct_human / 100)


def adjust_im(new_ease: int, base_im: int = 100) -> int:
    return math.ceil(ANKI_DEFAULT_EASE * base_im / new_ease)


def unique(_list: List[dict], key) -> List[dict]:
    added_ids = set()
    result = []
    for item in _list:
        if not item[key] in added_ids:
            result.append(item)
            added_ids.add(item['id'])
    return result


def update_group_settings(group_conf: Dict[str, Any], ease_human: int, im_human: int) -> None:
    # default = `2500`, LowKey target will be `1310`
    group_conf['new']['initialFactor'] = ez_factor_anki(ease_human)

    # default is `1.0`, LowKey target will be `1.92`
    group_conf['rev']['ivlFct'] = ivl_factor_anki(im_human)

    mw.col.decks.set_config_id_for_deck_dict(group_conf, group_conf['id'])
    print(f"Updated Option Group: {group_conf['name']}.")


def maybe_update_groups(dids: List[int], ease_human: int, im_human: int) -> None:
    if not config.get('update_options_groups'):
        return

    if whole_col_selected(dids):
        dconfs = mw.col.decks.all_config()
    else:
        dconfs = [mw.col.decks.config_dict_for_deck_id(did) for did in dids]

    for dconf in unique(dconfs, 'id'):
        update_group_settings(dconf, ease_human, im_human)


def get_decks_info() -> List[Tuple[str, int]]:
    decks = sorted(mw.col.decks.all_names_and_ids(), key=lambda deck: deck.name)
    result = [('Whole Collection', whole_collection_id()), ]
    result.extend([(deck.name, deck.id) for deck in decks])
    return result


def emit_running(func: Callable[["RefoldEase"], None]):
    def wrapper(self: "RefoldEase"):
        self.running.emit(True)  # type: ignore
        func(self)
        self.running.emit(False)  # type: ignore

    return wrapper


class RefoldEase(QObject):
    running = pyqtSignal(bool)

    def __init__(self, dids: List[int], factor_human: int, im_human: int):
        super().__init__()
        self.dids = dids
        self.factor_human = factor_human
        self.im_human = im_human
        qconnect(self.running, self.on_running)
        maybe_sync_before()

    @emit_running
    def run(self) -> None:
        reset_ease(self.dids, self.factor_human)
        maybe_update_groups(self.dids, self.factor_human, self.im_human)

    def on_running(self, running: bool) -> None:
        if not running:
            self.finalize()

    def finalize(self) -> None:
        maybe_notify_done(self.factor_human)
        maybe_sync_after()
