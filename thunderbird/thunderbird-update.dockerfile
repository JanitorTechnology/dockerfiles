FROM janx/thunderbird
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages (temporarily regain administrator privileges).
USER root
RUN apt-get update -q && apt-get upgrade -qy
USER user

# Update and rebuild Thunderbird's source code.
RUN cd /home/user/thunderbird \
 && python client.py checkout \
 && ./mozilla/mach clobber \
 && ./mozilla/mach build
