from collections import defaultdict
import datetime
from pprint import pprint as pp
import random
import string


from anki.hooks import addHook
from anki.exporting import Exporter
from anki.utils import (
    ids2str,
    splitFields,
)
from aqt import mw
from aqt.qt import (
    QAction,
    QMenu,
    Qt,
)
from aqt.utils import (
    askUser,
    getSaveFile,
    showWarning,
    tooltip,
)


from .libs import xlsxwriter

from .config import anki_21_version, gc
from .card_properties import current_card_deck_properties
from .gpl import RowAndColumn
from .helper_functions import (
    now,
    getSaveDir,
)
from .string_processing import(
    esc,
    processText,
)
from .writing import (
    write_rows_to_csv,
    write_to_multiple_csvs,
    write_to_multiworksheeet_xlsx,
    write_worksheet,
)


def make_row_list_for_card(cid, columns_to_export, keephtml):
    card = mw.col.getCard(cid)
    note = card.note()
    model = card.model()
    props = current_card_deck_properties(card)
    outlist = []
    for i in columns_to_export:
        thisstr = ""
        if i == "question":
            q = esc(card.q(), keephtml)
            if gc('card_export_maxLength'):
                q = q[:gc('card_export_maxLength')]
            thisstr = q
        elif i == "answer":
            a = esc(card.a(), keephtml)
            if gc('card_export_maxLength'):
                a = a[:gc('card_export_maxLength')]
            thisstr = a
        elif i == "tags":
            thisstr = ' '.join(note.tags)
        elif i in props:
            thisstr = props[i]
        elif i.startswith("card_export_column__field_"):
            try:
                cd = gc(i)
            except:
                tooltip("Error in Add-on. '%s' not in config. Aborting ..." % i)
            else:
                if isinstance(cd, dict):
                    field_to_fetch = cd.get(props["c_NoteType"])
                    if field_to_fetch:
                        for index, fi in enumerate(model['flds']):
                            if fi['name'] == field_to_fetch:
                                fiCnt = note.fields[index]
                                fiCnt = processText(fiCnt, keephtml)
                                if gc('card_export_maxLength'):
                                    fiCnt = fiCnt[:gc('card_export_maxLength')]
                                thisstr = fiCnt
        outlist.append(thisstr)
    return outlist


def info_for_cids_to_list_of_lists(browser, cids, keephtml):
    columns_to_export = gc("card_export__columns")
    if not columns_to_export:
        tooltip("error in add-on config. No setting found which columns to export. Aborting ...")
        return
    rows = []
    rows.append(columns_to_export)
    for c in cids:
        rows.append(make_row_list_for_card(c, columns_to_export, keephtml))
    return rows


def get_notes_info(cids, keephtml):
    # extracted from anki.exporting.TextNoteExporter
    d = {}
    for e in [m['id'] for m in mw.col.models.all()]:
        d[str(e)] = []
    for id, modelid, mod, flds, tags in mw.col.db.execute("""
select id, mid, mod, flds, tags from notes
where id in
(select nid from cards
where cards.id in %s)""" % ids2str(cids)):
        row = []
        if gc("note_export_include_note_id"):
            row.append(str(id))
        if gc("note_export_include_modification_time"):
            row.append(str(mod))
        if gc("note_export_include_tags"):
            row.append(tags.strip())
        row.extend([processText(f, keephtml) for f in splitFields(flds)])
        d[str(modelid)].append(row)
    # remove empty keys
    out = {k: v for k, v in d.items() if v}
    return out


def uniquify_clean_model_names_in_dict(dol, limitlength):
    # dict of lists
    # model names, but don't just rely on model names in case someone uses "Basic_" and "Basic*" ...    
    illegal = [">", "<", ":", "/", "\\", '"', "|", "*", ]
    out = {}
    for k, v in dol.items():
        modelname = ""
        for c in mw.col.models.get(int(k))['name']:
            modelname += c if c not in illegal else "_"
        if limitlength:
            newkey = modelname[:15] + '___' + k  # Excel worksheet names must be under 30 chars
        else:
            newkey = modelname + '___' + k
        out[newkey] = v
    return out


def add_column_names_for_notes_as_first_element(dol):
    # dict of lists
    for k, v in dol.items():
        cnames = []
        if gc("note_export_include_note_id"):
            cnames.append("note_id")
        if gc("note_export_include_modification_time"):
            cnames.append("last modification time")
        if gc("note_export_include_tags"):
            cnames.append("tags")
        model = mw.col.models.get(int(k))
        fnames = [f['name'] for f in model["flds"]]
        cnames.extend(fnames)
        v.insert(0, cnames)
    return dol


def save_helper(browser, ftype, notesonly):
    if notesonly and ftype == "csv":
        out = getSaveDir(parent=browser,
                title="Select Folder for csv files for exported notes",
                identifier_for_last_user_selection="notesOnlyCsvExport")
    nownow = now()
    if notesonly and ftype == "xlsx":
        out = getSaveFile(browser,
                "Export underyling notes from Browser to xlsx",  # windowtitle
                "export_notes_xlsx",  # dir_description - used to remember last user choice
                "Notes as xlsx",  # key
                '.xlsx',  # ext
                'Anki_notes__%s.xlsx' % nownow)  # filename  # aqt.mw.pm.name
    if not notesonly and ftype == "csv": 
        out = getSaveFile(browser,
                "Export Selected From Browser to Csv",  # windowtitle
                "export_cards_csv",  # dir_description - used to remember last user choice
                "Cards as CSV",  # key
                '.csv',  # ext
                'Anki_cards___%s.csv' % nownow)  # filename
    if not notesonly and ftype == "xlsx":
        out = getSaveFile(browser,
                "Export Selected From Browser to Xlsx",
                "export_cards_xlsx",
                "Cards as Xlsx",
                '.xlsx',
                'Anki_cards___%s.xlsx' % nownow)
    return out


def exp(browser, ftype, keephtml, notesonly):
    cids = browser.selectedCards()
    if cids:
        msg = f'Exporting many {"notes" if notesonly else "cards"} might take a while. Continue?'
        if not askUser(msg, defaultno=True):
            return
        save_path = save_helper(browser, ftype, notesonly)
        if not save_path:
            return
        mw.progress.start(immediate=True)
        try:
            if notesonly:
                rows_by_model_raw = get_notes_info(sorted(cids), keephtml)
                if gc("row_on_top_has_column_names"):
                    rows_by_model_raw = add_column_names_for_notes_as_first_element(rows_by_model_raw)
                if ftype == "csv":
                    rows_by_model = uniquify_clean_model_names_in_dict(rows_by_model_raw, False)
                    write_to_multiple_csvs(save_path, rows_by_model)
                elif ftype == "xlsx":
                    rows_by_model = uniquify_clean_model_names_in_dict(rows_by_model_raw, True)
                    write_to_multiworksheeet_xlsx(save_path, rows_by_model)
            else:
                rows = info_for_cids_to_list_of_lists(browser, sorted(cids), keephtml)
                if ftype == "csv":
                    write_rows_to_csv(save_path, rows, True)
                elif ftype == "xlsx":
                    workbook = xlsxwriter.Workbook(save_path)
                    worksheet = workbook.add_worksheet()
                    write_worksheet(workbook, worksheet, rows)
                    workbook.close()
        finally:
            mw.progress.finish()
            tooltip('Export to "%s" finished' % str(save_path), period=6000)


def exp_browser_visible___up_to_44(browser, ftype, keephtml):
    save_path = save_helper(browser, ftype, notesonly=False)
    if not save_path:
        return

    # mw.progress.start(immediate=True)
    rows = []  # list of lists

    # write header
    thisrow = []

    # order of visible cols is saved/restored with restoreHeader(hh, "editor") which calls saveState/restoreState
    # https://doc.qt.io/qt-5/qheaderview.html#visualIndex
    # visualIndex

    m = browser.model
    tv = browser.form.tableView
    hh = tv.horizontalHeader()
    columns_type_visualPos = {}
    columns_type_displayName = {}
    visible_column_count = m.columnCount(0)
    
    thisrow = ["" for i in range(visible_column_count)]
    for i in range(visible_column_count):
        typ = m.columnType(i)
        vidx = hh.visualIndex(i)
        columns_type_visualPos[typ] = vidx
        name = m.headerData(i, Qt.Horizontal, Qt.DisplayRole)
        columns_type_displayName[typ] = name
        thisrow[vidx] = name
    rows.append(thisrow)

    for r in browser.form.tableView.selectionModel().selectedRows():
        """
        type(r) = PyQt5.QtCore.QModelIndex
        type(r.row()) = int
        """
        thisrow = ["" for i in range(visible_column_count)]
        this_card_field_names = None
        for cidx in range(visible_column_count):
            typ = m.columnType(cidx)
            vidx = columns_type_visualPos[typ]
            field_content = ""
            if keephtml and (typ.startswith('_field_') or typ == "noteFld"):
                if not this_card_field_names:
                    cid = browser.model.cards[r.row()]
                    thiscard = browser.col.getCard(cid)
                    note_type = thiscard.note_type()
                    this_card_field_names = browser.mw.col.models.fieldNames(note_type)
                    note = thiscard.note()
                if typ == "noteFld":
                    # code taken from browser.DataModel.columnData
                    field_content = note.fields[browser.mw.col.models.sortIdx(note_type)]
                else:
                    for fidx, fname in enumerate(this_card_field_names):
                        if fname in typ:
                            field_content = note.fields[fidx]
                content = field_content
            else:
                item_index = RowAndColumn(r.row(), cidx)
                content = browser.model.columnData(item_index)
            thisrow[vidx] = content
        rows.append(thisrow)

    if ftype == "csv":
        write_rows_to_csv(save_path, rows, True)
    elif ftype == "xlsx":
        workbook = xlsxwriter.Workbook(save_path)
        worksheet = workbook.add_worksheet()
        write_worksheet(workbook, worksheet, rows)
        workbook.close()

    # mw.progress.finish()
    tooltip('Export to "%s" finished' % str(save_path), period=6000)


def exp_browser_visible___45_and_newer(browser, ftype, keephtml):
    save_path = save_helper(browser, ftype, notesonly=False)
    if not save_path:
        return

    rows = []  # list of lists

    # write column names (header) as first row
    column_names__technical = browser.table._model._state.active_columns  # not translated
    column_names__displayed = []
    for i in range(browser.table._model.len_columns()):
        column_names__displayed.append(browser.table._model.headerData(i, Qt.Orientation.Horizontal, Qt.ItemDataRole.DisplayRole))
    rows.append(column_names__displayed)

    for qmi in browser.table._selected():  # qmi = QModelIndex
        # row_idx = qmi.row()
        nid = browser.table._model.get_note_ids([qmi])[0]  #  browser.table._model.get_note_id(qmi) is not in .45
        
        this_card_field_names = None
        row = browser.table._model.get_row(qmi)
        contents_one_row = ["" for i in range(len(column_names__displayed))]
        for idxc, cell in enumerate(row.cells):
            this_column_name_technical = column_names__technical[idxc]
            field_content = ""
            if keephtml and (this_column_name_technical.startswith('_field_') or this_column_name_technical == "noteFld"):
                if not this_card_field_names:
                    note = browser.col.get_note(nid)
                    note_type = browser.col.models.get(note.mid)  # same as Card.note_type (which was Card.model)
                    if anki_21_version <= 49:
                        this_card_field_names = browser.mw.col.models.fieldNames(note_type)
                    else:
                        this_card_field_names = browser.mw.col.models.field_names(note_type)
                if this_column_name_technical == "noteFld":
                    # code taken from browser.DataModel.columnData
                    note_type_sort_field = note_type.get("sortf")
                    field_content = note.fields[note_type_sort_field]
                else:
                    for fidx, fname in enumerate(this_card_field_names):
                        if fname in this_column_name_technical:
                            field_content = note.fields[fidx]
                content = field_content
            else:
                content = row.cells[idxc].text
            contents_one_row[idxc] = content          
        rows.append(contents_one_row)

    if ftype == "csv":
        write_rows_to_csv(save_path, rows, True)
    elif ftype == "xlsx":
        workbook = xlsxwriter.Workbook(save_path)
        worksheet = workbook.add_worksheet()
        write_worksheet(workbook, worksheet, rows)
        workbook.close()

    tooltip('Export to "%s" finished' % str(save_path), period=6000)


def exp_brows_visi(browser, ftype, keephtml):
    if anki_21_version <= 44:
        exp_browser_visible___up_to_44(browser, ftype, keephtml)
    else:
        exp_browser_visible___45_and_newer(browser, ftype, keephtml)


def setupMenu(browser):
    o = QMenu("Export selected ...", browser)
    browser.form.menuEdit.addMenu(o)


    s = QMenu("cards with columns shown", browser)
    o.addMenu(s)


    s_csv = QMenu(".. to csv", browser)
    s.addMenu(s_csv)

    s_xls = QMenu(".. to xlsx", browser)
    s.addMenu(s_xls)

    u = s_csv.addAction("keep html")
    u.triggered.connect(lambda _, b=browser: exp_brows_visi(b, ftype="csv", keephtml=True))

    u = s_csv.addAction("remove html")
    u.triggered.connect(lambda _, b=browser: exp_brows_visi(b, ftype="csv", keephtml=False))

    u = s_xls.addAction("keep html")
    u.triggered.connect(lambda _, b=browser: exp_brows_visi(b, ftype="xlsx", keephtml=True))

    u = s_xls.addAction("remove html")
    u.triggered.connect(lambda _, b=browser: exp_brows_visi(b, ftype="xlsx", keephtml=False))




    m = QMenu("according to add-on settings", browser)
    o.addMenu(m)

    c = QMenu("cards to ...", browser)
    m.addMenu(c)

    c_csv = QMenu(".. to csv", browser)
    c.addMenu(c_csv)

    c_xls = QMenu(".. to xlsx", browser)
    c.addMenu(c_xls)


    n = QMenu("underlying notes of selected cards to ...", browser)
    m.addMenu(n)

    ncsv = QMenu(".. to csv, one file per note type ...", browser)
    n.addMenu(ncsv)

    nxls = QMenu(".. to xlsx ", browser)
    n.addMenu(nxls)


    u = c_csv.addAction("keep html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="csv", keephtml=True, notesonly=False))

    u = c_csv.addAction("remove html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="csv", keephtml=False, notesonly=False))

    u = c_xls.addAction("keep html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="xlsx", keephtml=True, notesonly=False))

    u = c_xls.addAction("remove html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="xlsx", keephtml=False, notesonly=False))


    u = ncsv.addAction("keep html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="csv", keephtml=True, notesonly=True))

    u = ncsv.addAction("remove html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="csv", keephtml=False, notesonly=True))

    u = nxls.addAction("keep html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="xlsx", keephtml=True, notesonly=True))

    u = nxls.addAction("remove html")
    u.triggered.connect(lambda _, b=browser: exp(b, ftype="xlsx", keephtml=False, notesonly=True))

addHook("browser.setupMenus", setupMenu)
