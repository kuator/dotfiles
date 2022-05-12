#!/bin/bash

set -e

tempdir=$(mktemp -d)
mkdir "$tempdir/extract"
cd "$tempdir/extract"
set +e
unzip /usr/lib/firefox/browser/omni.ja

# if [ "$?" -ne 0 ]; then
#   echo >&2 "Unexpected exit code from unzip"
#   exit 1
# fi

set -e
patch -p1 <<EOF
--- ./chrome/browser/content/browser/browser.xhtml	2010-01-01 00:00:00.000000000 +0100
+++ ./chrome/browser/content/browser/browser.xhtml.new	2020-03-22 19:32:36.283963602 +0100
@@ -313,6 +313,8 @@
     <key keycode="VK_BACK" command="cmd_handleBackspace" reserved="false"/>
     <key keycode="VK_BACK" command="cmd_handleShiftBackspace" modifiers="shift" reserved="false"/>
-    <key id="goBackKb"  keycode="VK_LEFT" command="Browser:Back" modifiers="alt"/>
-    <key id="goForwardKb"  keycode="VK_RIGHT" command="Browser:Forward" modifiers="alt"/>
+    <key id="goBackKb"  key="a" command="Browser:Back" modifiers="alt" reserved="true"/>
+    <key id="goForwardKb"  key="s" command="Browser:Forward" modifiers="alt" reserved="true"/>
+    <key id="goNextTab"  key="e" command="Browser:NextTab" modifiers="accel"/>
+    <key id="goPrevTab"  key="d" command="Browser:PrevTab" modifiers="accel"/>
     <key id="goBackKb2" data-l10n-id="nav-back-shortcut-alt" command="Browser:Back" modifiers="accel"/>
     <key id="goForwardKb2" data-l10n-id="nav-fwd-shortcut-alt" command="Browser:Forward" modifiers="accel"/>
EOF

zip -qr9XD ../omni.ja *
sudo bash -c "cp /usr/lib/firefox/browser/omni.ja /usr/lib/firefox/browser/omni.ja.orig ; cat $tempdir/omni.ja >/usr/lib/firefox/browser/omni.ja"
find ~/.cache/mozilla/firefox -type d -name startupCache | xargs rm -rf
cd /
rm -r "$tempdir"
