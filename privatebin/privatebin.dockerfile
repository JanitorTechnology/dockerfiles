FROM janitortechnology/ubuntu-dev
MAINTAINER PrivateBin <support@privatebin.org>

# Download PHP dependencies
USER root
RUN apt-get update && \
    apt-get -y install --no-install-recommends nginx php-fpm php-gd php-sqlite3 phpunit && \
    rm -rf /var/lib/apt/lists/*

# Configure php-fpm & supervisord
RUN mkdir -p /run/php && \
    sed -ri "s/^;daemonize = .*$/daemonize = no/" /etc/php/7.0/fpm/php-fpm.conf && \
    sed -ri "s/^(user|group) = .*$/\1 = user/" /etc/php/7.0/fpm/pool.d/www.conf && \
    echo '[include]\nfiles = /etc/supervisor/conf.d/*.conf' >> /etc/supervisord.conf

# Download JS dependencies
USER user
RUN npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types && \
    ln -s $(npm config get prefix)/lib/node_modules /home/user/node_modules

# Prepare Git repository
RUN git clone https://github.com/PrivateBin/PrivateBin /home/user/privatebin

# Deploy unit test wrapper script, nginx & supervisord configurations
COPY unit-test.sh /usr/local/bin/unit-test
COPY nginx-site.conf /etc/nginx/sites-available/default
COPY nginx-php.conf /etc/supervisor/conf.d/

WORKDIR /home/user/privatebin

# Configure the IDEs to use PrivateBin's source directory as workspace.
ENV WORKSPACE /home/user/privatebin/

# Nginx port
EXPOSE 80

# Configure Janitor for PrivateBin
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
