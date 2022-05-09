import csv
import datetime
import os

from .libs import xlsxwriter

from .config import gc


def write_to_multiple_csvs(dir, rows_by_model):
    for modelname, list_of_lists in rows_by_model.items():
        outfile = os.path.join(dir, modelname + ".csv")
        write_rows_to_csv(outfile, list_of_lists, False)


def write_to_multiworksheeet_xlsx(path, rows_by_model):
    workbook = xlsxwriter.Workbook(path)
    for modelNameAdj, list_of_lists in rows_by_model.items():
        worksheet = workbook.add_worksheet(modelNameAdj)
        write_worksheet(workbook, worksheet, list_of_lists)
    workbook.close()


def write_rows_to_csv(path, list_of_rows, iscards):
    with open(path, mode="w", encoding="utf-8") as file:
        """
- `format_csv_dialect`: You can set 'excel', 'excel-tab', 'unix'.
- `format_csv_delimiter`: if empty uses the default delimiter of the selectd dialect. Must be
one-character string - otherwise python's csv module won't work. , see 
https://docs.python.org/3.6/library/csv.html#csv.Dialect.delimiter. If you set a delimiter here
that's longer than one character this add-on will not use python's csv module for exporting. Instead
it writes a text file and ignores the settings format_csv_dialect, format_csv_quotechar, 
format_csv_quotechar.
- `format_csv_quotechar`: if empty uses the default delimiter of the selectd dialect. A 
one-character string, see https://docs.python.org/3.6/library/csv.html#csv.Dialect.quotechar
- `format_csv_quoting`: if empty uses the default delimiter of the selectd dialect. You can 
set "ALL", "MINIMAL", "NONNUMERIC", "NONE", for details see
https://docs.python.org/3.6/library/csv.html#csv.QUOTE_ALL
        """
        csvdialect = gc("format_csv_dialect")
        if csvdialect not in ['excel', 'excel-tab', 'unix']:
            csvdialect = 'excel'  # this is the default value for csv.writer in 3.6
        fmtparams = {}
        quoting = gc("format_csv_quoting")
        if quoting:
            quoting = quoting.upper()
        if quoting not in ["ALL", "MINIMAL", "NONNUMERIC", "NONE"]:
            quoting = ""
        if quoting:
            fmtparams["quoting"] = eval("csv.QUOTE_%s" % quoting)
        quotechar = gc("format_csv_quotechar")
        if quotechar and len(quotechar) == 1:
            fmtparams["quotechar"] = quotechar
        delimiter = gc("format_csv_delimiter")
        if delimiter and (delimiter in ["\t"] or len(delimiter) == 1):
            fmtparams["delimiter"] = delimiter        
        if not delimiter or delimiter in ["\t"] or len(delimiter) == 1:
            # for k, v in fmtparams.items():
            #     print(str(k), str(v))
            writer = csv.writer(file, csvdialect, **fmtparams)
            if iscards and gc("row_on_top_has_column_names"):
                writer.writerow(gc("card_export__columns"))  # column names
            # https://docs.python.org/3/library/csv.html#csv.csvwriter.writerows
            writer.writerows(list_of_rows)
        elif len(delimiter) >= 2:
            fmtline = lambda li: delimiter.join(str(e) for e in li)
            if iscards and gc("row_on_top_has_column_names"):
                file.write(fmtline(gc("card_export__columns")) + "\n")
            for r in list_of_rows:
                file.write(fmtline(r) + '\n')


def write_worksheet(workbook, worksheet, list_of_rows):
    date_format = workbook.add_format({'num_format': 'yyyy-mm-dd'})
    int_format = workbook.add_format({'num_format': '0'})
    for row, celllist in enumerate(list_of_rows):
        for index, cell in enumerate(celllist):
            # TODO: save time by directly getting the proper format instead of reconverting multiple
            # times from "Additional Card Fields" component ...
            isint = False
            isdate = False
            try:
                cell = int(cell)
            except:
                try:
                    cell = datetime.datetime.strptime(cell, '%Y-%m-%d')
                except:
                    pass
                else:
                    isdate = True
            else:
                isint = True
            if isdate:
                worksheet.write(row, index, cell, date_format)
            elif isint:
                worksheet.write(row, index, cell, int_format)
            else:
                worksheet.write(row, index, cell)