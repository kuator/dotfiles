# Copyright: (C) 2021 Ren Tatsumoto <tatsu at autistici.org>
# License: GNU AGPL, version 3 or later; http://www.gnu.org/copyleft/gpl.html

from aqt import mw
from aqt.qt import *
from aqt.utils import openLink
from aqt.webview import AnkiWebView

from .consts import *


def tweak_window(dialog: QDialog) -> None:
    try:
        mw.garbage_collect_on_dialog_finish(dialog)
    except AttributeError:
        pass
    try:
        from aqt.utils import disable_help_button
        disable_help_button(dialog)
    except ImportError:
        pass


class AboutDialog(QDialog):
    def __init__(self, parent: QWidget, *args, **kwargs):
        super().__init__(parent=parent or mw, *args, **kwargs)
        tweak_window(self)
        self.setWindowModality(Qt.ApplicationModal)
        self.setWindowTitle(f'{DIALOG_NAME} {ADDON_SERIES}')
        self.setSizePolicy(self.make_size_policy())
        self.setMinimumSize(320, 240)
        self.setLayout(self.make_root_layout())

    def make_about_webview(self, html_content: str) -> AnkiWebView:
        webview = AnkiWebView(parent=self)
        webview.setProperty("url", QUrl("about:blank"))
        webview.stdHtml(html_content, js=[])
        webview.setMinimumSize(480, 320)
        return webview

    def make_button_box(self) -> QWidget:
        def ok():
            but = QPushButton('Ok')
            qconnect(but.clicked, self.accept)
            but.setFixedHeight(BUTTON_HEIGHT)
            return but

        def community():
            but = QPushButton('Join our community')
            qconnect(but.clicked, lambda: openLink(COMMUNITY_LINK))
            but.setIcon(QIcon(CHAT_ICON_PATH))
            but.setIconSize(QSize(ICON_SIDE_LEN, ICON_SIDE_LEN))
            but.setFixedHeight(BUTTON_HEIGHT)
            return but

        def donate():
            but = QPushButton('Donate')
            qconnect(but.clicked, lambda: openLink(DONATE_LINK))
            but.setIcon(QIcon(DONATE_ICON_PATH))
            but.setIconSize(QSize(ICON_SIDE_LEN, ICON_SIDE_LEN))
            but.setFixedHeight(BUTTON_HEIGHT)
            return but

        but_box = QHBoxLayout()
        but_box.addWidget(ok())
        but_box.addStretch()
        but_box.addWidget(community())
        but_box.addWidget(donate())

        return but_box

    def make_root_layout(self) -> QLayout:
        root_layout = QVBoxLayout()
        root_layout.addWidget(self.make_about_webview(ABOUT_MSG))
        root_layout.addLayout(self.make_button_box())
        return root_layout

    def make_size_policy(self) -> QSizePolicy:
        size_policy = QSizePolicy(QSizePolicy.Preferred, QSizePolicy.Minimum)
        size_policy.setHorizontalStretch(0)
        size_policy.setVerticalStretch(0)
        size_policy.setHeightForWidth(self.sizePolicy().hasHeightForWidth())
        return size_policy


def menu_root_entry() -> QMenu:
    if not hasattr(mw.form, 'ajt_root_menu'):
        mw.form.ajt_root_menu = QMenu(ADDON_SERIES, mw)
        mw.form.menubar.insertMenu(mw.form.menuHelp.menuAction(), mw.form.ajt_root_menu)
        mw.form.ajt_root_menu.addAction(create_about_action(mw.form.ajt_root_menu))
        mw.form.ajt_root_menu.addSeparator()
    return mw.form.ajt_root_menu


def create_about_action(parent: QWidget) -> QAction:
    def open_about_dialog():
        dialog = AboutDialog(mw)
        return dialog.exec()

    action = QAction(f'{DIALOG_NAME}...', parent)
    qconnect(action.triggered, open_about_dialog)
    return action
