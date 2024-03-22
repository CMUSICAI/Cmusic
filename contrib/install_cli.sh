 #!/usr/bin/env bash

 # Execute this file to install the cmusicai cli tools into your path on OS X

 CURRENT_LOC="$( cd "$(dirname "$0")" ; pwd -P )"
 LOCATION=${CURRENT_LOC%CmusicAI-Qt.app*}

 # Ensure that the directory to symlink to exists
 sudo mkdir -p /usr/local/bin

 # Create symlinks to the cli tools
 sudo ln -s ${LOCATION}/CmusicAI-Qt.app/Contents/MacOS/cmusicaid /usr/local/bin/cmusicaid
 sudo ln -s ${LOCATION}/CmusicAI-Qt.app/Contents/MacOS/cmusicai-cli /usr/local/bin/cmusicai-cli
