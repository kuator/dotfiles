## Refold Ease configuration

*Anki needs to be restarted after changing the config.*

****

* `adjust_ease_when_reviewing` - Just before you answer each card,
the add-on checks its Ease factor and sets it back to `new_starting_ease_percent` if needed.
* `advanced_options` - Enables advanced options when the dialog is shown.
* `force_sync_in_one_direction` - Force changes in one direction on next sync.
Set to `true` if you notice that the updated ease values aren't
getting pushed from desktop to AnkiWeb.
"Full" sync causes a window to pop up asking whether you would like to "Upload to AnkiWeb"
or "Download from AnkiWeb". Choose **"Upload to AnkiWeb"**.
Your other devices can download on next sync.
* `modify_db_directly` - Change ease factors of cards directly through `mw.col.db.execute`.
This method may be faster, but it always requires a full sync afterwards
because Anki won't know that card properties have been changed.
* `new_starting_ease_percent` - Your desired new Ease. Normally this value should be set to `131`.
* `show_reset_notification` - Set to `false` if you've seen the reset ease dialog enough times, or if it bugs you.
* `sync_after_reset` - Sync your Anki collection after changing the Ease.
* `sync_before_reset` - If you would like to sync your Anki collection with an AnkiWeb account
before changing the Ease factors of your cards.
* `update_options_groups` - Whether to go through each `Options Group`
and update its `Starting Ease` and `Interval Modifier` after the cards have been reset.

****

If you enjoy this add-on, please consider supporting my work by
**[pledging your support on Patreon](https://www.patreon.com/bePatron?u=43555128)**.
Thank you so much!
