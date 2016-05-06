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
 && git rebase-update \
 && gclient sync --delete --jobs=18 \
 && ninja -C out/Default chrome -j18
