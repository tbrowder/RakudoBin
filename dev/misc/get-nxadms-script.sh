#!/bin/bash

# original:
#   curl -1sLf \
#     'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.deb.sh' \
#     | sudo -E bash

# I want to download the script
   curl -1sLf \
     'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.deb.sh' > nxd.script
