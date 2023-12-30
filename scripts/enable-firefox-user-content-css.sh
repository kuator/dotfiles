#!/bin/bash

cd ~/.mozilla/firefox/

PROFPATH=$(grep "Default=.*\.default-release*" "$HOME/.mozilla/firefox/profiles.ini" | cut -d"=" -f2)

echo $PROFPATH
cd $PROFPATH

if [ -f 'user.js' ]; then
    echo "user.js exists"
else 

cat  <<'EOF' > user.js
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("webchannel.allowObject.urlWhitelist", "https://content.cdn.mozilla.net https://support.mozilla.org https://install.mozilla.org https://accounts.firefox.com");
user_pref("extensions.webextensions.restrictedDomains", "");
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);
# user_pref("xpinstall.signatures.required", false);
EOF

fi

mkdir -p chrome && cd chrome

if [ -f 'userContent.css' ]; then
    echo "userContent.css exists"
else 

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

@-moz-document regexp("^moz-extension://.*welcome.html.*$") {
  .content { 
    background-color: #777; 
  }
}

@-moz-document regexp("^moz-extension://.*settings.html.*$") {
  .content { 
    background-color: #777; 
  }
}
EOF

fi
