# License: GNU GPL, version 3 or later; http://www.gnu.org/copyleft/gpl.html
# Copyright: Steve AW <steveawa@gmail.com>
#             fickle_123@hotmail.com
# from 46837454, Export Browsers card list contents to CSV file Enhanced, 2014-12-06


class RowAndColumn():
    def __init__(self, r, c):
        self.irow = r
        self.icolumn = c
    def row(self):
        return self.irow
    def column(self):
        return self.icolumn
