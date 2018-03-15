FROM janx/ubuntu-dev
<<<<<<< HEAD
<<<<<<< HEAD

<<<<<<< HEAD
# Get dependencies
=======
>>>>>>> Add DSpace to Janitor
=======

# Get dependencies
>>>>>>> Add comments and fix ports
=======
# Get updates if there are any
>>>>>>> Update DSpace to DSpace-Angular
RUN sudo apt-get update -q \
  && sudo apt-get upgrade -qy \
  && sudo apt-get install -qy

<<<<<<< HEAD
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
=======
# Get source code
<<<<<<< HEAD
>>>>>>> Add comments and fix ports
RUN git clone https://github.com/dspace/dspace /home/user/dspace
WORKDIR /home/user/dspace

# Setup configurations
COPY local.cfg /home/user/dspace/dspace/config/
RUN sudo chown user:user /home/user/dspace/dspace/config/local.cfg

# Add an SQL user
COPY create_user.sql /tmp/
<<<<<<< HEAD
>>>>>>> Add DSpace to Janitor
=======
# Add psql to supervisor configuration
>>>>>>> Add comments and fix ports
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
=======
# Add symlinks for tomcat8
>>>>>>> Add comments and fix ports
RUN sudo ln -s /home/user/dspace/webapps/ /var/lib/tomcat8/webapps/
=======
RUN git clone https://github.com/dspace/dspace-angular /home/user/dspace-angular
WORKDIR /home/user/dspace-angular

RUN yarn run global \
  && yarn install
>>>>>>> Update DSpace to DSpace-Angular

# Add Janitor configurations
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> Add DSpace to Janitor
=======
# For db and tomcat8
>>>>>>> Add comments and fix ports
EXPOSE 5432 8080
=======
# For Angular
EXPOSE 3000
>>>>>>> Update DSpace to DSpace-Angular
