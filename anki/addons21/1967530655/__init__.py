"""
Add-on for Anki 2.1
Export Selected Cards from the Browser to csv. You can determine the columns in the csv
via the add-on config dialog.

Copyright: - Ankitects Pty Ltd and contributors
           - 2019 ijgnd
           - for bundled files see below

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.



This add-on uses the file gpl.py covered by the following copyright and  
permission notice:

    License: GNU GPL, version 3 or later; http://www.gnu.org/copyleft/gpl.html
    Copyright: Steve AW <steveawa@gmail.com>
               fickle_123@hotmail.com




This add-on incorporates work (xlsxwriter) covered by the following copyright and  
permission notice:

    XlsxWriter is released under a BSD license.

    Copyright (c) 2013, John McNamara <jmcnamara@cpan.org> All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted 
    provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice, this list of 
        conditions and the following disclaimer.
        2. Redistributions in binary form must reproduce the above copyright notice, this list of 
        conditions and the following disclaimer in the documentation and/or other materials provided 
        with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR 
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
    OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.

    The views and conclusions contained in the software and documentation are those of the authors 
    and should not be interpreted as representing official policies, either expressed or implied, 
    of the FreeBSD Project.
    


This add-on also bundles the file fractions.py from cpython which has this license,
https://docs.python.org/3.6/license.html

    Terms and conditions for accessing or otherwise using Python
    PSF LICENSE AGREEMENT FOR PYTHON 3.6.9

    1. This LICENSE AGREEMENT is between the Python Software Foundation ("PSF"), and
    the Individual or Organization ("Licensee") accessing and otherwise using Python
    3.6.9 software in source or binary form and its associated documentation.

    2. Subject to the terms and conditions of this License Agreement, PSF hereby
    grants Licensee a nonexclusive, royalty-free, world-wide license to reproduce,
    analyze, test, perform and/or display publicly, prepare derivative works,
    distribute, and otherwise use Python 3.6.9 alone or in any derivative
    version, provided, however, that PSF's License Agreement and PSF's notice of
    copyright, i.e., "Copyright © 2001-2019 Python Software Foundation; All Rights
    Reserved" are retained in Python 3.6.9 alone or in any derivative version
    prepared by Licensee.

    3. In the event Licensee prepares a derivative work that is based on or
    incorporates Python 3.6.9 or any part thereof, and wants to make the
    derivative work available to others as provided herein, then Licensee hereby
    agrees to include in any such work a brief summary of the changes made to Python
    3.6.9.

    4. PSF is making Python 3.6.9 available to Licensee on an "AS IS" basis.
    PSF MAKES NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED.  BY WAY OF
    EXAMPLE, BUT NOT LIMITATION, PSF MAKES NO AND DISCLAIMS ANY REPRESENTATION OR
    WARRANTY OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE
    USE OF PYTHON 3.6.9 WILL NOT INFRINGE ANY THIRD PARTY RIGHTS.

    5. PSF SHALL NOT BE LIABLE TO LICENSEE OR ANY OTHER USERS OF PYTHON 3.6.9
    FOR ANY INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES OR LOSS AS A RESULT OF
    MODIFYING, DISTRIBUTING, OR OTHERWISE USING PYTHON 3.6.9, OR ANY DERIVATIVE
    THEREOF, EVEN IF ADVISED OF THE POSSIBILITY THEREOF.

    6. This License Agreement will automatically terminate upon a material breach of
    its terms and conditions.

    7. Nothing in this License Agreement shall be deemed to create any relationship
    of agency, partnership, or joint venture between PSF and Licensee.  This License
    Agreement does not grant permission to use PSF trademarks or trade name in a
    trademark sense to endorse or promote products or services of Licensee, or any
    third party.

    8. By copying, installing or otherwise using Python 3.6.9, Licensee agrees
    to be bound by the terms and conditions of this License Agreement.



"""


import os
import sys

try:
    import Fraction
except ModuleNotFoundError:
    if sys.version_info[1] <= 6:
        # let's hope for the best for python version 3.5 or earlier. Not tested since 2.15 uses 3.6
        folder_for_version = "missing_stdlib_36"
    elif sys.version_info[1] == 7:
        folder_for_version = "missing_stdlib_37"
    elif sys.version_info[1] == 8:
        folder_for_version = "missing_stdlib_38"
    elif sys.version_info[1] == 9:
        folder_for_version = "missing_stdlib_39"
    elif sys.version_info[1] == 10:
        folder_for_version = "missing_stdlib_310"
    else:
        # let's hope for the best for python versions 3.11 or later. Not tested since 3.10 is the
        # latest version in 2022-01
        folder_for_version = "missing_stdlib_310"

    addon_path = os.path.dirname(__file__)
    sys.path.insert(0, os.path.join(addon_path, "libs", folder_for_version))


from . import export
