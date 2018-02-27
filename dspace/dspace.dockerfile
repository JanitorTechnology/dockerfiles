FROM janx/ubuntu-dev
<<<<<<< HEAD

# Get dependencies
=======
>>>>>>> Add DSpace to Janitor
RUN sudo apt-get update -q \
  && sudo apt-get upgrade -qy \
  && sudo apt-get install -qy \
     ant \
     maven \
     postgresql \
     tomcat8

<<<<<<< HEAD
# Get source code
RUN git clone https://github.com/dspace/dspace /home/user/dspace
WORKDIR /home/user/dspace

# Setup configurations
COPY local.cfg /home/user/dspace/dspace/config/
RUN sudo chown user:user /home/user/dspace/dspace/config/local.cfg

# Add an SQL user
COPY create_user.sql /tmp/
# Add psql to supervisor configuration
=======
RUN git clone https://github.com/dspace/dspace /home/user/dspace
WORKDIR /home/user/dspace

COPY local.cfg /home/user/dspace/dspace/config
RUN sudo chown user:user /home/user/dspace/dspace/config/local.cfg

COPY create_user.sql /tmp/
>>>>>>> Add DSpace to Janitor
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

<<<<<<< HEAD
# Add symlinks for tomcat8
RUN sudo ln -s /home/user/dspace/webapps/ /var/lib/tomcat8/webapps/

# Configure the IDEs to use DSpace's source directory as workspace.
ENV WORKSPACE /home/user/dspace/

# Add Janitor configurations
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

# For db and tomcat8
=======
RUN sudo ln -s /home/user/dspace/webapps/ /var/lib/tomcat8/webapps/

COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

>>>>>>> Add DSpace to Janitor
EXPOSE 5432 8080
