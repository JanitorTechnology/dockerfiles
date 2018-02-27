FROM janx/ubuntu-dev
RUN sudo apt-get update -q \
  && sudo apt-get upgrade -qy \
  && sudo apt-get install -qy \
     ant \
     maven \
     postgresql \
     tomcat8

RUN git clone https://github.com/dspace/dspace /home/user/dspace
WORKDIR /home/user/dspace

COPY local.cfg /home/user/dspace/dspace/config
RUN sudo chown user:user /home/user/dspace/dspace/config/local.cfg

COPY create_user.sql /tmp/
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

RUN sudo ln -s /home/user/dspace/webapps/ /var/lib/tomcat8/webapps/

COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

EXPOSE 5432 8080
