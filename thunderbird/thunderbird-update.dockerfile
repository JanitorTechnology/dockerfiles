FROM janx/thunderbird
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update and rebuild Thunderbird's source code.
RUN cd /home/user/thunderbird \
 && python client.py checkout \
 && ./mozilla/mach clobber \
 && ./mozilla/mach build
