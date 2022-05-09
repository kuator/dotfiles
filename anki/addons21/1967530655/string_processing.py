import re

from aqt import mw
from .config import anki_21_version, gc

if anki_21_version <= 49:
    from anki.utils import stripHTML as anki_utils_stripHTML
else:
    from anki.utils import strip_html as anki_utils_stripHTML  

"""
anki.utils in 2019-11

reComment = re.compile("(?s)<!--.*?-->")
reStyle = re.compile("(?si)<style.*?>.*?</style>")
reScript = re.compile("(?si)<script.*?>.*?</script>")
reTag = re.compile("(?s)<.*?>")
reEnts = re.compile(r"&#?\w+;")
reMedia = re.compile("(?i)<img[^>]+src=[\"']?([^\"'>]+)[\"']?[^>]*>")

def stripHTML(s):
    s = reComment.sub("", s)
    s = reStyle.sub("", s)
    s = reScript.sub("", s)
    s = reTag.sub("", s)
    s = entsToTxt(s)
    return s
"""

def exporter_stripHTML(text):
    # very basic conversion to text
    s = text
    s = re.sub(r"(?i)<(br ?/?|div|p)>", " ", s)
    s = re.sub(r"\[sound:[^]]+\]", "", s)
    s = anki_utils_stripHTML(s)
    s = re.sub(r"[ \n\t]+", " ", s)
    s = s.strip()
    return s


def exporter_escapeText(text):
    # original comment:
    "     Escape newlines, tabs, CSS and quotechar."
    #     fixme: we should probably quote fields with newlines
    #     instead of converting them to spaces
    #
    #
    #
    # the fixme note was introduced in commit 47940680d27dca0c2f4bca2acd83630414c56db3
    # in 2015-11-17. The commit message reads:
    """
don't convert newlines into br tags in export

fixes https://anki.tenderapp.com/discussions/ankidesktop/15795-export
-error-doubling-br-tags

This code dates back a few years, and was probably a naive solution
for files breaking when exported with newlines. Ideally we should be
preserving the newlines and wrapping the field in quotes, but since
some people may be relying on exported files not to be quoted, we'll
wait to change this until the next major release. For now, we'll use
a space instead, which should not alter the appearance of the
rendered HTML.
"""
    if gc('remove_newlines', True):
        text = text.replace("\n", " ")
        text = text.replace("\t", " " * 8)
        text = re.sub("(?i)<style>.*?</style>", "", text)
        text = re.sub(r"\[\[type:[^]]+\]\]", "", text)
        if "\"" in text:
            text = "\"" + text.replace("\"", "\"\"") + "\""
        return text
    else:
        pass


def processText(text, keephtml):
    if not keephtml:
        text = exporter_stripHTML(text)
    text = exporter_escapeText(text)
    return text


def esc(s, keephtml):
    # from anki.exporting.TextCardExporter.doExport
    # strip off the repeated question in answer if exists
    s = re.sub("(?si)^.*<hr id=answer>\n*", "", s)
    # Exporter.processText in 2019-11 replaces linebreaks with spaces
    return processText(s, keephtml)
