FROM janitortechnology/discourse
MAINTAINER Michael Howell "michael@notriddle.com"

# Upgrade all packages
RUN sudo apt-get update -q && sudo apt-get upgrade -qy

# Update Discourse and migrate dependencies
RUN cd /home/user/discourse \
 && git pull --rebase origin master \
 && (sudo runuser -u postgres -- /usr/lib/postgresql/9.5/bin/postgres -D /etc/postgresql/9.5/main/ 2>&1 > /dev/null &) \
 && (sudo runuser -u redis -- redis-server /etc/redis/redis.conf 2>&1 > /dev/null &) \
 && sleep 5 \
 && bundle install \
 && bundle exec rake db:migrate \
 && RAILS_ENV=test bundle exec rake db:migrate
