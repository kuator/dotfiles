# Copyright: Ren Tatsumoto <tatsu at autistici.org>
# License: GNU AGPL, version 3 or later; http://www.gnu.org/licenses/agpl.html

from typing import List, Optional

from aqt import mw
from aqt.qt import *
from aqt.utils import openLink, restoreGeom, saveGeom

from .config import config, write_config
from .consts import *
from .refoldease import RefoldEase, get_decks_info, adjust_im


######################################################################
# UI
######################################################################

def expanding_combobox(min_width=200) -> QComboBox:
    box = QComboBox()
    box.setMinimumWidth(min_width)
    box.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
    return box


class DialogUI(QDialog):
    _booleans = (
        "update_options_groups",
        "sync_after_reset",
        "force_sync_in_one_direction",
        "adjust_ease_when_reviewing",
    )

    @classmethod
    def make_checkboxes(cls):
        return {key: QCheckBox(key.replace('_', ' ').capitalize()) for key in cls._booleans}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.easeSpinBox = QSpinBox()
        self.imSpinBox = QSpinBox()
        self.defaultEaseImSpinBox = QSpinBox()
        self.checkboxes = self.make_checkboxes()
        self.deckComboBox = expanding_combobox()
        self.run_button = QPushButton(RUN_BUTTON_TEXT)
        self.advanced_opts_groupbox = self.create_advanced_options_group()
        self.button_box = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel | QDialogButtonBox.Help)
        self._setup_ui()

    def _setup_ui(self):
        self.setWindowTitle(ADDON_NAME)
        self.setLayout(self.setup_outer_layout())
        self.add_tooltips()

    def setup_outer_layout(self):
        vbox = QVBoxLayout()
        vbox.setSpacing(10)
        vbox.addLayout(self.create_deck_selection_group())
        vbox.addWidget(self.advanced_opts_groupbox)
        vbox.addStretch(1)
        vbox.addWidget(self.button_box)
        return vbox

    def create_deck_selection_group(self):
        hbox = QHBoxLayout()
        hbox.addWidget(QLabel("Deck"))
        hbox.addWidget(self.deckComboBox, stretch=1)
        hbox.addWidget(self.run_button)
        return hbox

    def create_advanced_options_group(self):
        groupbox = QGroupBox("Advanced Options")
        groupbox.setCheckable(True)

        vbox = QVBoxLayout()
        groupbox.setLayout(vbox)

        vbox.addLayout(self.create_ease_group())
        vbox.addLayout(self.create_check_box_group())

        return groupbox

    def create_ease_group(self):
        grid = QGridLayout()
        spinboxes = {
            "IM multiplier": self.defaultEaseImSpinBox,
            "Desired new Ease": self.easeSpinBox,
            "Recommended new IM": self.imSpinBox,
        }
        for y_idx, label in enumerate(spinboxes):
            for h_idx, widget in enumerate((QLabel(label), spinboxes[label], QLabel("%"))):
                grid.addWidget(widget, y_idx, h_idx)

        return grid

    def create_check_box_group(self):
        vbox = QVBoxLayout()
        for widget in self.checkboxes.values():
            vbox.addWidget(widget)
        return vbox

    def add_tooltips(self):
        self.defaultEaseImSpinBox.setToolTip(
            "Your Interval Modifier when your Starting Ease was 250%.\n"
            "You can find it by going to \"Deck options\" > \"Reviews\" > \"Interval Modifier\"."
        )
        self.easeSpinBox.setToolTip(
            "Your desired new Ease. The recommended value is 131%.\n"
            "Note: Because Anki resets Starting Ease back to 250% on each force sync if it's set to 130%,\n"
            "The lowest possible Ease supported by the add-on is 131%."
        )
        self.imSpinBox.setToolTip(
            "This is your new Interval Modifier after applying this Ease setup."
        )
        self.checkboxes['update_options_groups'].setToolTip(
            "Update Interval Modifier and Starting Ease in every Options Group\n"
            "or just in the Options Group associated with the deck you've selected."
        )
        self.checkboxes['sync_after_reset'].setToolTip(
            "Sync collection when the task is done."
        )
        self.checkboxes['force_sync_in_one_direction'].setToolTip(
            "Mark the collection as needing force sync."
        )
        self.checkboxes['adjust_ease_when_reviewing'].setToolTip(
            "When you review a card, its Ease is going to be adjusted back\n"
            "to the value you set here, if needed."
        )
        self.button_box.button(QDialogButtonBox.Ok).setToolTip("Save settings and close the dialog.")
        self.button_box.button(QDialogButtonBox.Cancel).setToolTip("Discard settings and close the dialog.")
        self.button_box.button(QDialogButtonBox.Help).setToolTip("Open the Anki guide.")


######################################################################
# The addon's window
######################################################################


class RefoldEaseDialog(DialogUI):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.set_minimums()
        self.set_maximums()
        self.set_default_values()
        self.connect_ui_elements()
        self.thread: Optional[QThread] = None
        self.worker: Optional[RefoldEase] = None

    def show(self) -> None:
        super().show()
        self.populate_decks()
        restoreGeom(self, ADDON_NAME)

    def set_minimums(self) -> None:
        self.defaultEaseImSpinBox.setMinimum(0)
        self.imSpinBox.setMinimum(0)
        self.easeSpinBox.setMinimum(MIN_EASE)

    def set_maximums(self) -> None:
        self.defaultEaseImSpinBox.setMaximum(MAX_EASE)
        self.easeSpinBox.setMaximum(MAX_EASE)
        self.imSpinBox.setMaximum(MAX_EASE)

    def set_default_values(self) -> None:
        widget: QCheckBox

        for conf_key, widget in self.checkboxes.items():
            widget.setChecked(config.get(conf_key, False))

        self.defaultEaseImSpinBox.setValue(100)
        self.easeSpinBox.setValue(config.get('new_starting_ease_percent'))
        self.advanced_opts_groupbox.setChecked(config.get('advanced_options', False))
        self.update_im_spin_box()

    def connect_ui_elements(self) -> None:
        qconnect(self.defaultEaseImSpinBox.editingFinished, self.update_im_spin_box)
        qconnect(self.easeSpinBox.editingFinished, self.update_im_spin_box)

        qconnect(self.defaultEaseImSpinBox.valueChanged, self.update_im_spin_box)
        qconnect(self.easeSpinBox.valueChanged, self.update_im_spin_box)

        qconnect(self.run_button.clicked, self.on_run)

        qconnect(self.button_box.accepted, self.accept)
        qconnect(self.button_box.rejected, self.reject)
        qconnect(self.button_box.helpRequested, lambda: openLink(ANKI_SETUP_GUIDE))

    def populate_decks(self) -> None:
        self.deckComboBox.clear()
        for deck in get_decks_info():
            self.deckComboBox.addItem(*deck)

    def update_im_spin_box(self) -> None:
        self.imSpinBox.setValue(adjust_im(self.easeSpinBox.value(), self.defaultEaseImSpinBox.value()))

    def get_selected_dids(self) -> List[int]:
        selected_deck_name = self.deckComboBox.currentText()
        selected_dids = [self.deckComboBox.currentData()]

        for deck in mw.col.decks.all_names_and_ids():
            if deck.name.startswith(selected_deck_name + "::"):
                selected_dids.append(deck.id)

        return selected_dids

    def update_global_config(self) -> None:
        for conf_key, widget in self.checkboxes.items():
            config[conf_key] = widget.isChecked()

        config['new_starting_ease_percent'] = self.easeSpinBox.value()
        config['advanced_options'] = self.advanced_opts_groupbox.isChecked()

        write_config()

    def accept(self):
        self.update_global_config()
        saveGeom(self, ADDON_NAME)
        super().accept()

    def on_run(self) -> None:
        if self.run_button.isEnabled():
            self.update_global_config()
            self.thread = QThread()
            self.worker = RefoldEase(
                dids=self.get_selected_dids(),
                factor_human=self.easeSpinBox.value(),
                im_human=self.imSpinBox.value(),
            )
            self.worker.moveToThread(self.thread)
            self.worker.running.connect(lambda running: self.run_button.setEnabled(not running))
            self.worker.running.connect(lambda running: self.thread.quit() if not running else None)
            self.thread.started.connect(self.worker.run)
            self.thread.start()


######################################################################
# Entry point
######################################################################

dialog = RefoldEaseDialog(parent=mw)


def init():
    from .ajt_common import menu_root_entry
    root_menu = menu_root_entry()

    # create a new menu item
    action = QAction(ADDON_NAME, root_menu)
    # set it to call testFunction when it's clicked
    qconnect(action.triggered, dialog.show)
    # and add it to the tools menu
    root_menu.addAction(action)
    # adjust ease factor before review, if enabled
