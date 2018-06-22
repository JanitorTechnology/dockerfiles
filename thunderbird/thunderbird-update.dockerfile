FROM janitortechnology/thunderbird
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update and rebuild Thunderbird's source code.
RUN cd /home/user/thunderbird \
 && hg pull --update \
 && hg -R comm pull --update \
 && mach clobber \
 && mach build
