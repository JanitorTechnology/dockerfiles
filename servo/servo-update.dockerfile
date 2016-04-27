FROM janx/servo
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages (temporarily regain administrator privileges).
USER root
RUN apt-get update -q && apt-get upgrade -qy
USER user

# Update and rebuild Servo's source code.
RUN cd /home/user/servo \
 && git pull --rebase origin master \
 && ./mach build -d
