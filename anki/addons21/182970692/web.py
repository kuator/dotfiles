from typing import Tuple, Any, Optional

from anki.hooks import wrap
from anki.notes import Note
from aqt import gui_hooks, mw
from aqt.editor import Editor
from aqt.webview import WebContent

from .common import contains_audio_tag, play_text
from .config import config


def handle_js_messages(handled: Tuple[bool, Any], message: str, context: Any) -> Tuple[bool, Any]:
    if not isinstance(context, Editor) or context.note is None:
        return handled

    if message == 'get_fields_with_audio':
        return True, [contains_audio_tag(field) for field in context.note.fields]

    cmd = message.split(":", maxsplit=1)

    if cmd[0] == "play_field":
        play_text(context.note.fields[int(cmd[1])])
        return True, None

    return handled


def appropriate_context(context: Editor) -> bool:
    if config.get('context') == 'both':
        return True

    if config.get('context') == 'add' and context.addMode is True:
        return True

    if config.get('context') == 'browser' and context.addMode is False:
        return True

    return False


def load_play_button_js(web_content: WebContent, context: Optional[Any]) -> None:
    if isinstance(context, Editor):
        addon_package = context.mw.addonManager.addonFromModule(__name__)
        base_path = f"/_addons/{addon_package}/web"

        web_content.css.append(f"{base_path}/play_button.css")
        web_content.js.append(f"{base_path}/play_button.js")


def on_load_note(js: str, _: Note, editor: Editor) -> str:
    if appropriate_context(editor):
        return js + "; BrowserPlayButton.load_icons(); "
    else:
        return js + "; BrowserPlayButton.hide_icons(); "


def on_bridge_cmd_wrapper(self: Editor, cmd: str):
    # If a field has been edited, reload play buttons on fields in case audio was added or removed.
    if cmd.startswith("key:") and appropriate_context(self):
        self.web.eval("BrowserPlayButton.load_icons()")


def init():
    mw.addonManager.setWebExports(__name__, r"(web|icons)/.*\.(js|css|png)")
    gui_hooks.webview_will_set_content.append(load_play_button_js)
    gui_hooks.webview_did_receive_js_message.append(handle_js_messages)
    gui_hooks.editor_will_load_note.append(on_load_note)
    Editor.onBridgeCmd = wrap(Editor.onBridgeCmd, on_bridge_cmd_wrapper, "after")
