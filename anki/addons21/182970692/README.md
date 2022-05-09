<p align="center"><img src="icons/play.png" alt="icon" width="128px"></p>

# AJT Browser Play Button

[![Rate on AnkiWeb](https://glutanimate.com/logos/ankiweb-rate.svg)](https://ankiweb.net/shared/info/182970692)
[![Chat](https://img.shields.io/badge/chat-join-green)](https://tatsumoto-ren.github.io/blog/join-our-community.html)
[![Channel](https://shields.io/badge/channel-subscribe-blue?logo=telegram&color=3faee8)](https://t.me/ajatt_tools)
[![Patreon](https://img.shields.io/badge/patreon-support-orange)](https://www.patreon.com/bePatron?u=43555128)
![GitHub](https://img.shields.io/github/license/Ajatt-Tools/BrowserPlayButton)

This tiny add-on adds a play button to the Anki Browser's toolbar.
When clicked, it looks for `[sound:...]`-tags on the selected note
and plays them in the order of their appearance on the note's fields.
If there is selected text, the action is limited to the sound tags
that appear only in the selected text.

If you select "Play field" in the context menu,
the action is limited to the currently selected field.

Each field that contains audio has a play button next to its name.
Pressing on the button plays all audio files in the field.

Audio can be directly played with a shortcut: `alt + m`.

A demo can be viewed on
<a target="_blank" href="https://youtu.be/9rpHtTrk2TM"><img src=".github/youtube_logo.webp" width="80px"></a>.

<p align="center"><img src=".github/play_button.webp" alt="screenshot"></p>
<p align="center"><i>Screenshot.</i></p>

## Installation

Install from [AnkiWeb](https://ankiweb.net/shared/info/182970692), or manually with `git`:

```
$ git clone 'https://github.com/Ajatt-Tools/BrowserPlayButton.git' ~/.local/share/Anki2/addons21/BrowserPlayButton
```

## Configuration

To configure the add-on, open the Anki Add-on Menu
via `Tools` > `Add-ons` and select `AJT Browser Play Button`.
Then click the `Config` button on the right-side of the screen.

Alternatively, open the Anki Browser and click `Edit` > `AJT Browser Play Button settings...`.

<p align="center"><img src=".github/settings.webp" alt="screenshot"></p>
<p align="center"><i>Settings.</i></p>

If you hover over a setting, it brings up a tooltip explaining what it does.

## Acknowledgements

* [Play audio in browser](https://ankiweb.net/shared/info/388541036). The idea and initial implementation.
* [Ze Frozen Fields](https://ankiweb.net/shared/info/94610912). Field buttons functionality.
[GitHub link](https://github.com/hgiesel/anki_frozen_fields).
