# Copyright: Ren Tatsumoto <tatsu at autistici.org>
# License: GNU AGPL, version 3 or later; http://www.gnu.org/licenses/agpl.html

from typing import Tuple

from anki.cards import Card
from aqt import gui_hooks
from aqt.reviewer import Reviewer

from .config import config
from .refoldease import ez_factor_anki


def is_review(card: Card) -> bool:
    return card.type == 2 and card.queue == 2


def should_adjust_ease(card: Card) -> bool:
    return all((
        config.get('adjust_ease_when_reviewing') is True,
        card.factor >= ez_factor_anki(130),
        is_review(card),
    ))


def adjust_ease(card: Card) -> None:
    if not should_adjust_ease(card):
        return

    required_factor_human = config.get('new_starting_ease_percent')
    required_factor_anki = ez_factor_anki(required_factor_human)

    if card.factor != required_factor_anki:
        card.factor = required_factor_anki
        print(f"RefoldEase: Card #{card.id}'s Ease has been adjusted to {required_factor_human}%.")


def on_reviewer_will_answer_card(ease_tuple: Tuple, _reviewer: Reviewer, card: Card) -> Tuple:
    adjust_ease(card)
    return ease_tuple


def init():
    gui_hooks.reviewer_will_answer_card.append(on_reviewer_will_answer_card)
