import time

from aqt import mw

from .helper_functions import (
    allRevsForCard,
    due_day, 
    fmt_long_string,
    percent_overdue,
    valueForOverdue,
    timespan,
)

from .config import gc


def current_card_deck_properties(card):
    if card.odid:
        conf = mw.col.decks.confForDid(card.odid)
        source_deck_name = mw.col.decks.get(card.odid)['name']
    else:
        conf = mw.col.decks.confForDid(card.did)
        source_deck_name = ""

    formatted_steps = ''
    for i in conf.get('new', {}).get('delays', []):
        formatted_steps += ' -- ' + timespan(i * 60)

    #############
    # from anki.stats.py
    (cnt, total) = mw.col.db.first(
        "select count(), sum(time)/1000 from revlog where cid = ?", card.id)
    first = mw.col.db.scalar(
        "select min(id) from revlog where cid = ?", card.id)
    last = mw.col.db.scalar(
        "select max(id) from revlog where cid = ?", card.id)

    def date(tm):
        return time.strftime("%Y-%m-%d", time.localtime(tm))

    template = card.template()
    model = card.model()
    p = dict()
    # (mostly) Card Stats as seen in Browser
    p["c_Added"] = date(card.id/1000)
    p["c_FirstReview"] = date(first/1000) if first else ""
    p["c_LatestReview"] = date(last/1000) if last else ""
    p["allrevs"] = allRevsForCard(card.id)
    p["c_Due"] = due_day(card)
    p["c_Interval_fmt"] = timespan(card.ivl * 86400) if card.queue == 2 else ""
    p["c_Interval_in_Days"] = card.ivl
    p["c_Ease"] = "%d" % (card.factor/10.0)
    p["c_Ease_percent"] = str("%d%%" % (card.factor/10.0))
    p["c_Reviews"] = "%d" % card.reps
    p["c_Lapses"] = "%d" % card.lapses
    p["c_AverageTime"] = timespan(total / float(cnt)) if cnt else ""
    p["c_TotalTime"] = timespan(total) if cnt else ""
    p["c_Position"] = card.due if card.queue == 0 else ""
    p["c_CardType"] = template['name']
    p["c_NoteType"] = model['name']
    p["c_model_id"] = model['id']
    p["c_Deck"] = mw.col.decks.name(card.did)
    p["c_NoteID"] = card.nid
    p["c_CardID"] = card.id

    # other useful info
    p["cnt"] = cnt
    p["total"] = total
    p["card_ivl_str"] = str(card.ivl)
    p["dueday"] = str(due_day(card))
    p["value_for_overdue"] = str(valueForOverdue(card))
    p["overdue_percent"] = str(percent_overdue(card))
    p["actual_ivl"] = str(card.ivl + valueForOverdue(card))
    p["c_type"] = card.type
    p["deckname"] = mw.col.decks.get(card.did)['name']
    p["source_deck_name"] = source_deck_name
    p["now"] = time.strftime('%Y-%m-%d %H:%M', time.localtime(card.id/1000))

    # Deck Options
    p["d_OptionGroupID"] = conf.get('id',"")
    p["d_OptionGroupName"] = conf.get('name', "")
    p["d_OptionGroupName_fmt"] = fmt_long_string(conf.get('name',""), gc('optiongroup_names_length', 20))
    p["d_IgnoreAnsTimesLonger"] = conf.get("maxTaken", "")
    p["d_ShowAnswerTimer"] = conf.get("timer", "")
    p["d_Autoplay"] = conf.get("autoplay", "")
    p["d_Replayq"] = conf.get("replayq", "")
    p["d_IsDyn"] = conf.get("dyn", "")
    p["d_usn"] = conf.get("usn", "")
    p["d_mod"] = conf.get("mod", "")
    p["d_new_steps"] = conf.get('new', {}).get('delays')
    p["d_new_steps_str"] = str(conf.get('new', {}).get('delays', ""))
    p["d_new_steps_fmt"] = formatted_steps
    p["d_new_order"] = conf.get('new', {}).get('order', "")
    p["d_new_NewPerDay"] = conf.get('new', {}).get('perDay', "")
    p["d_new_GradIvl"] = str( conf.get('new', {}).get('ints', ["", ""])[0] )
    p["d_new_EasyIvl"] = str( conf.get('new', {}).get('ints', ["", ""])[1] )
    p["d_new_StartingEase"] = conf.get('new', {}).get('initialFactor', 0) / 10
    p["d_new_BurySiblings"] = conf.get('new', {}).get('bury')
    p["d_new_sep"] = conf.get('new', {}).get("separate", "")  # unused
    p["d_rev_perDay"] = conf.get('rev', {}).get('perDay', "")
    p["d_rev_easybonus"] = str(int(100 * conf.get('rev', {}).get('ease4', 0)))
    p["d_rev_IntMod_int"] = int(100 * conf.get('rev', {}).get('ivlFct', 0))
    p["d_rev_IntMod_str"] = str(int(100 * conf.get('rev', {}).get('ivlFct', 0)))
    p["d_rev_MaxIvl"] = conf.get('rev', {}).get('maxIvl', "")
    p["d_rev_BurySiblings"] = conf.get('rev', {}).get('bury', "")
    p["d_rev_minSpace"] = conf.get('rev', {}).get("minSpace", "")  # unused
    p["d_rev_fuzz"] = conf.get('rev', {}).get("fuzz", "")     # unused
    p["d_lapse_steps"] = conf.get('lapse', {}).get('delays', "")
    p["d_lapse_steps_str"] = str(conf.get('lapse', {}).get('delays', ""))
    p["d_lapse_NewIvl_int"] = int(100 * conf.get('lapse', {}).get('mult', 0))
    p["d_lapse_NewIvl_str"] = str(int(100 * conf.get('lapse', {}).get('mult', 0)))
    p["d_lapse_MinInt"] = conf.get('lapse', {}).get('minInt', "")
    p["d_lapse_LeechThresh"] = conf.get('lapse', {}).get('leechFails', "")
    p["d_lapse_LeechAction"] = conf.get('lapse', {}).get('leechAction', "")
    return p
