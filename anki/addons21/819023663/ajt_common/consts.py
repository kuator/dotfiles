# Copyright: (C) 2021 Ren Tatsumoto <tatsu at autistici.org>
# License: GNU AGPL, version 3 or later; http://www.gnu.org/copyleft/gpl.html

import os

ADDON_SERIES = 'AJT'
DIALOG_NAME = 'About'
ANKIWEB_LINK = 'https://ankiweb.net/shared/byauthor/1425504015'
WEBSITE_LINK = 'https://tatsumoto.neocities.org/'
COMMUNITY_LINK = 'https://tatsumoto.neocities.org/blog/join-our-community.html'
DONATE_LINK = 'https://tatsumoto.neocities.org/blog/donating-to-tatsumoto.html'
TG_LINK = 'https://t.me/ajatt_tools'
GITHUB_LINK = 'https://github.com/Ajatt-Tools'

IMG_DIR = os.path.join(os.path.normpath(os.path.dirname(__file__)), 'img')
CHAT_ICON_PATH = os.path.join(IMG_DIR, 'element.svg')
DONATE_ICON_PATH = os.path.join(IMG_DIR, 'patreon_logo.svg')

BUTTON_HEIGHT = 32
ICON_SIDE_LEN = 18

STYLES = '''
<style>
a { color: SteelBlue; }
h2 { text-align: center; }
body { margin: 0 4px 0; }
</style>
'''

ABOUT_MSG = f'''
{STYLES}
<h2>Ajatt Tools add-ons</h2>
<p>
    Thanks so much for using the
    <a href="{ANKIWEB_LINK}">AJT</a>
    add-on series!
</p>
<p>
    If you would like to ensure you don't miss any AJT updates or new releases,
    please consider visiting our
    <a href="{WEBSITE_LINK}">website</a>,
    joining
    <a href="{COMMUNITY_LINK}">our community</a>
    and following us on
    <a href="{TG_LINK}">Telegram</a>!
</p>
<p>
    If you want to participate in the development,
    explore the <a href="{GITHUB_LINK}">Ajatt Tools GitHub organization</a>.
</p>
<p>
    If the add-ons have been useful to you, please consider
    <a href="{DONATE_LINK}">supporting my work</a>!
    It allows me to put more time and focus into developing them.
    Thank you!
</p>
'''
