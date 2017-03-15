FROM janx/ubuntu-dev
MAINTAINER Jan Keromnes "janx@linux.com"

# Download Janitor's source code and install its dependencies.
RUN git clone --recursive https://github.com/JanitorTechnology/janitor /home/user/janitor \
 && cd /home/user/janitor \
 && npm update
WORKDIR /home/user/janitor

# Add Janitor database with default values for local development.
ADD db.json /home/user/janitor/
RUN sudo chown user:user /home/user/janitor/db.json

# Expose all Janitor server ports.
EXPOSE 8080 8081
