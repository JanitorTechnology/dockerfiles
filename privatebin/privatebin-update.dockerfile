FROM janitortechnology/privatebin
MAINTAINER PrivateBin <support@privatebin.org>

# Upgrade all packages
RUN sudo apt-get update -q && \
    sudo apt-get upgrade -qy && \
    sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/user/privatebin

# Update PrivateBin
RUN git pull --rebase origin master
