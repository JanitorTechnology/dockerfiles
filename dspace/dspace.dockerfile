FROM janx/ubuntu-dev

# Get dependencies
RUN sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
     ant \
     maven \
     postgresql \
     tomcat8
  && sudo rm -rf /var/lib/apt/lists/*

# Get source code
RUN git clone https://github.com/dspace/dspace /home/user/dspace
WORKDIR /home/user/dspace

# Setup configurations
COPY local.cfg /home/user/dspace/dspace/config/
RUN sudo chown user:user /home/user/dspace/dspace/config/local.cfg

# Add an SQL user
COPY create_user.sql /tmp/
# Add psql to supervisor configuration
COPY supervisord-append.conf /tmp/
RUN sudo chown user:user /tmp/create_user.sql \
   && sudo chown user:user /tmp/supervisord-append.conf \
   && sudo service postgresql start \
   && sudo -u postgres psql --file=/tmp/create_user.sql \
   && sudo -u postgres psql dspace -c "create extension pgcrypto;" \
   && cat /tmp/supervisord-append.conf | sudo tee -a /etc/supervisord.conf \
   && mvn clean install \
   && cd dspace/target/dspace-installer \
   && sudo ant update

# Add symlinks for tomcat8
RUN sudo ln -s /home/user/dspace/webapps/ /var/lib/tomcat8/webapps/

# Configure the IDEs to use DSpace's source directory as workspace.
ENV WORKSPACE /home/user/dspace/

# Add Janitor configurations
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

# For db and tomcat8
EXPOSE 5432 8080
