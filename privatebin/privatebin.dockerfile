FROM janitortechnology/ubuntu-dev
MAINTAINER PrivateBin <support@privatebin.org>

# Download deps
RUN sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends nginx php-fpm php-gd php-sqlite3 phpunit && \
    npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types && \

# Configure php-fpm
    sudo mkdir -p /run/php && \
    sudo sed -ri "s/^;daemonize = .*$/daemonize = no/" /etc/php/7.0/fpm/php-fpm.conf && \
    sudo sed -ri "s/^(user|group) = .*$/\1 = user/" /etc/php/7.0/fpm/pool.d/www.conf && \

# Configure supervisord
    sudo sh -c "echo '[program:php-fpm]\n\
user = user\n\
command = sudo /usr/sbin/php-fpm7.0\n\
autorestart = true\n\
[program:nginx]\n\
user = user\n\
command = sudo /usr/sbin/nginx -g \"daemon off;\"\n\
autorestart = true' >> /etc/supervisord.conf" && \

# Prepare Git repository & clean up
    git clone https://github.com/PrivateBin/PrivateBin /home/user/privatebin && \
    ln -s $(npm config get prefix)/lib/node_modules /home/user/node_modules && \
    sudo rm -rf /var/lib/apt/lists/*

# Deploy unit test wrapper script & nginx configuration
COPY unit-test.sh /usr/local/bin/unit-test
COPY nginx-site.conf /etc/nginx/sites-available/default

WORKDIR /home/user/privatebin

# Configure the IDEs to use PrivateBin's source directory as workspace.
ENV WORKSPACE /home/user/privatebin/

# Nginx port
EXPOSE 80

# Configure Janitor for PrivateBin
COPY janitor.json /home/user/
