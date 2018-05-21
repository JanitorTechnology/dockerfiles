FROM janitortechnology/chromium
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages (temporarily regain administrator privileges).
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update Chromium's depot_tools.
RUN cd /home/user/depot_tools \
 && git pull --rebase origin master

# Remove the parallelism limited Ninja alias and
# update and rebuild Chromium's source code.
RUN unalias ninja \
 && cd /home/user/chromium/src \
 && git fetch origin \
 && git reset --hard origin/master \
 && gclient sync --delete --jobs=`nproc` \
 && ninja -C out/Default chrome -j`nproc`
