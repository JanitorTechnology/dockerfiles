FROM janx/firefox
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages (temporarily regain administrator privileges).
USER root
RUN apt-get update -q && apt-get upgrade -qy
USER user

# Update Mozilla's moz-git-tools.
RUN cd /home/user/moz-git-tools \
 && git pull --rebase origin master \
 && git submodule update

# Update and rebuild Firefox's source code.
RUN cd /home/user/firefox \
 && git pull --rebase origin master \
 && ./mach build
