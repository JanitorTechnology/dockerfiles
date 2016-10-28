FROM janx/servo
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update and rebuild Servo's source code.
RUN cd /home/user/servo \
 && git pull --rebase origin master \
 && ./mach build -d
