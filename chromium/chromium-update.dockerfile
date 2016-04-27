FROM janx/chromium
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages (temporarily regain administrator privileges).
USER root
RUN apt-get update -q && apt-get upgrade -qy
USER user

# Update Chromium's depot_tools.
RUN cd /home/user/depot_tools \
 && git pull --rebase origin master

# Update and rebuild Chromium's source code.
RUN cd /home/user/chromium/src \
 && git fetch origin \
 && git reset --hard origin/master \
 && gclient sync --jobs=18 \
 && ninja -v -C out/Release chrome -j18
