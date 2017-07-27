FROM janitortechnology/janitor
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update Janitor's source code and its dependencies.
RUN cd /home/user/janitor \
 && git fetch origin \
 && git reset --hard origin/master \
 && npm update
