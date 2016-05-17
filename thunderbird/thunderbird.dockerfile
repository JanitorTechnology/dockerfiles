FROM janx/ubuntu-dev
MAINTAINER Philipp Kewisch "mozilla@kewis.ch"

# Install Thunderbird build dependencies.
# Packages after "mercurial" are from https://dxr.mozilla.org/mozilla-central/source/python/mozboot/mozboot/debian.py
RUN apt-get update -q \
 && apt-get upgrade -qy \
 && apt-get install -qy \
  mercurial \
  autoconf2.13 \
  build-essential \
  ccache \
  python-dev \
  python-pip \
  python-setuptools \
  unzip \
  uuid \
  zip \
  libasound2-dev \
  libcurl4-openssl-dev \
  libdbus-1-dev \
  libdbus-glib-1-dev \
  libgconf2-dev \
  libgtk2.0-dev \
  libgtk-3-dev \
  libiw-dev \
  libnotify-dev \
  libpulse-dev \
  libxt-dev \
  mesa-common-dev \
  python-dbus \
  yasm \
  xvfb \
 && pip install requests
ENV SHELL /bin/bash

# Don't be root.
USER user
WORKDIR /home/user

# Download Thunderbird's source code.
RUN hg clone https://hg.mozilla.org/comm-central/ thunderbird \
 && cd thunderbird \
 && python client.py checkout
WORKDIR thunderbird

# Add Thunderbird build configuration.
ADD .mozconfig /home/user/thunderbird/

# Set up Mercurial so mach doesn't complain.
RUN mkdir -p /home/user/.mozbuild \
 && ./mozilla/mach mercurial-setup -u

# Build Thunderbird.
RUN ./mozilla/mach build
