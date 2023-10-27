#!/bin/bash

cd ~/.mozilla/firefox/

# if [[ $(grep '\[Profile[^0]\]' profiles.ini) ]]
# then PROFPATH=$(grep -E '^\[Profile|^Path|^Default' profiles.ini | grep -1 '^Default=1' | grep '^Path' | cut -c6-)
# else PROFPATH=$(grep 'Path=' profiles.ini | sed 's/^Path=//')
# fi

PROFPATH=$(grep "Default=.*\.default-release*" "$HOME/.mozilla/firefox/profiles.ini" | cut -d"=" -f2)

echo $PROFPATH
cd $PROFPATH

cat  <<'EOF' > user.js
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("webchannel.allowObject.urlWhitelist", "https://content.cdn.mozilla.net https://support.mozilla.org https://install.mozilla.org https://accounts.firefox.com");
user_pref("extensions.webextensions.restrictedDomains", "");
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);
EOF

mkdir -p chrome && cd chrome

cat  <<'EOF' > userContent.css
@-moz-document regexp("about.*") {
  html {
    height: 100vh;
    background-color: #1C1B22;
  }
}


@-moz-document regexp("^moz-extension://.*search.html.*$") {
  .content { 
    background-color: #777; 
  }
}
EOF
