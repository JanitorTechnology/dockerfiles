FROM janx/firefox
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy && rustup update

# Update Mozilla's moz-git-tools.
RUN cd /home/user/moz-git-tools \
 && git pull --rebase origin master \
 && git submodule update

# Update and rebuild Firefox's source code.
RUN cd /home/user/firefox \
 && git pull --rebase origin master \
 && ./mach build
