- also see https://github.com/ankidroid/Anki-Android/wiki/Database-Structure
- for details see the source code of this add-on
- this add-on was tested with Anki 2.1.15 on Linux. It might not work on other platforms
or versions.

### csv options
for exporting to csv this add-on uses python's csv module. 
For details about this see https://docs.python.org/3.6/library/csv.html

You can set these values:

- `format_csv_dialect`: You can set 'excel', 'excel-tab', 'unix'.
- `format_csv_delimiter`: if empty uses the default delimiter of the selectd dialect. Must be
one-character string (or something like "\t" - otherwise python's csv module won't work. , see 
https://docs.python.org/3.6/library/csv.html#csv.Dialect.delimiter. If you set a delimiter here
that's longer than one character this add-on will not use python's csv module for exporting. Instead
it writes a text file and ignores the settings format_csv_dialect, format_csv_quotechar, 
format_csv_quotechar.
- `format_csv_quotechar`: if empty uses the default delimiter of the selectd dialect. A 
one-character string, ee https://docs.python.org/3.6/library/csv.html#csv.Dialect.quotechar
- `format_csv_quoting`: if empty uses the default delimiter of the selectd dialect. You can 
set "ALL", "MINIMAL", "NONNUMERIC", "NONE", for details see
https://docs.python.org/3.6/library/csv.html#csv.QUOTE_ALL

### export values
You can use the following values in your export:

- question, answer: These values produce the same content, that Anki's built-in "Cards in 
Plain Text ('*.txt)" uses. Mostly what you would see during reviews.
- field_a, field_b, field_*, ...: Instead of the whole question and answer you can also export 
fields from the underyling notes. You can add as many "field_" values as you like. In each
"field_" value you must list for each note type which field should be used. As an example see
the default config
- tags: whether tags should be included.

#### card related
- c_Added
- c_FirstReview
- c_LatestReview
- allrevs: date#type#rating(number,ease)#ivl#duedate#ease(factor)
- c_Due
- c_Interval_fmt
- c_Interval_in_Days
- c_Ease
- c_Ease_percent
- c_Reviews
- c_Lapses
- c_AverageTime
- c_TotalTime
- c_Position
- c_CardType
- c_NoteType
- c_model_id
- c_Deck
- c_NoteID
- c_CardID
- cnt
- total
- card_ivl_str
- dueday
- value_for_overdue
- overdue_percent
- actual_ivl
- c_type
- deckname
- source_deck_name
- now

#### Deck Options
- conf
- d_OptionGroupID
- d_OptionGroupName
- d_IgnoreAnsTimesLonger
- d_ShowAnswerTimer
- d_Autoplay
- d_Replayq
- d_IsDyn
- d_usn
- d_mod
- d_new_steps
- d_new_steps_str
- d_new_steps_fmt
- d_new_order
- d_new_NewPerDay
- d_new_GradIvl
- d_new_EasyIvl
- d_new_StartingEase
- d_new_BurySiblings
- d_new_sep
- d_rev_perDay
- d_rev_easybonus
- d_rev_IntMod_int
- d_rev_IntMod_str
- d_rev_MaxIvl
- d_rev_BurySiblings
- d_rev_minSpace
- d_rev_fuzz
- d_lapse_steps
- d_lapse_steps_str
- d_lapse_NewIvl_int
- d_lapse_NewIvl_str
- d_lapse_MinInt
- d_lapse_LeechThresh
- d_lapse_LeechAction
