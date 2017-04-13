FROM janx/janitor
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update Janitor's source code and its dependencies.
RUN cd /home/user/janitor \
 && git pull --rebase origin master \
 && npm update
