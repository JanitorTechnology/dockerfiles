FROM janx/firefox-hg
MAINTAINER Tim Nguyen "ntim.bugs@gmail.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy && rustup update

# Update and rebuild Firefox's source code.
RUN cd /home/user/firefox \
 && hg pull -u \
 && ./mach build
