# Based on Discourse's https://github.com/discourse/discourse/blob/master/docs/DEVELOPER-ADVANCED.md
# Does not use RVM because we're just running Discourse on here.
FROM janx/ubuntu-dev
MAINTAINER Michael Howell "michael@notriddle.com"

ADD supervisord-append.conf /tmp

# Download deps
RUN sudo apt-get -yqq install software-properties-common python-software-properties && \
    sudo add-apt-repository ppa:chris-lea/redis-server && \
    sudo add-apt-repository ppa:brightbox/ruby-ng && \
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo apt-get -yqq update && \
    sudo apt-get -yqq install nodejs ruby2.3 python-software-properties vim curl expect debconf-utils git-core build-essential zlib1g-dev libssl-dev openssl libcurl4-openssl-dev libreadline6-dev libpcre3 libpcre3-dev imagemagick postgresql postgresql-contrib-9.5 libpq-dev postgresql-server-dev-9.5 redis-server advancecomp gifsicle jhead jpegoptim libjpeg-turbo-progs optipng pngcrush pngquant gnupg2 ruby2.3-dev libsqlite3-dev && \
    echo 'gem: --no-document' >> /home/user/.gemrc && \
    sudo gem install bundler mailcatcher && \
    mkdir ~/.local && npm config set prefix '~/.local' && \
    npm install -g svgo phantomjs-prebuilt && \
    (cat /tmp/supervisord-append.conf | sudo tee /etc/supervisord.conf) && \
    sudo rm -f /tmp/supervisord-append.conf

# Set up database and source code repo
RUN sudo mkdir /var/run/postgresql/9.5-main.pg_stat_tmp && sudo chown postgres:postgres /var/run/postgresql/9.5-main.pg_stat_tmp && \
    (sudo runuser -u postgres -- /usr/lib/postgresql/9.5/bin/postgres -D /etc/postgresql/9.5/main/ 2>&1 > /dev/null &) && \
    (sudo runuser -u redis -- redis-server /etc/redis/redis.conf 2>&1 > /dev/null &) && \
    sleep 1 && \
    # Discourse will be running with user "user"
    sudo -u postgres createuser --superuser -Upostgres user && \
    sudo -u postgres psql -c "ALTER USER \"user\" WITH PASSWORD 'password';" && \
    # Discourse requires a UTF8 database, which means we have to change the PG template database to be UTF8
    sudo -u postgres psql -c "UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1'" && \
    sudo -u postgres psql -c "DROP DATABASE template1" && \
    sudo -u postgres psql -c "CREATE DATABASE template1 WITH ENCODING = 'UTF8' TEMPLATE template0" && \
    sudo -u postgres psql -c "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1'" && \
    # Redis will be run from supervisord, so don't do init.d-style forking
    sudo sed -i 's:daemonize yes:daemonize no:' /etc/redis/redis.conf && \
    # Download discourse, install dependencies, and initialize the database
    git clone https://github.com/discourse/discourse /home/user/discourse && \
    cd /home/user/discourse && \
    bundle install && \
    bundle exec rake db:create db:migrate && \
    RAILS_ENV=test bundle exec rake db:create db:migrate

WORKDIR /home/user/discourse

# Configure Cloud9 to use Discourse's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/discourse/" /etc/supervisord.conf

# Configure Janitor for Discourse
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
