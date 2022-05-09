from aqt import mw


def gc(arg, fail=False):
    # some TODOS ...
    if arg == "remove_newlines":
        return True
    else:
        return mw.addonManager.getConfig(__name__).get(arg, fail)


def get_anki_version():
    try:
        # 2.1.50+ because of bdd5b27715bb11e4169becee661af2cb3d91a443, https://github.com/ankitects/anki/pull/1451
        from anki.utils import point_version
    except:
        try:
            # introduced with 66714260a3c91c9d955affdc86f10910d330b9dd in 2020-01-19, should be in 2.1.20+
            from anki.utils import pointVersion
        except:
            # <= 2.1.19
            from anki import version as anki_version
            return int(anki_version.split(".")[-1]) 
        else:
            return pointVersion()
    else:
        return point_version()
anki_21_version = get_anki_version()
