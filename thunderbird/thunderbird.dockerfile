FROM janx/ubuntu-dev
MAINTAINER Philipp Kewisch "mozilla@kewis.ch"

# Install Thunderbird build dependencies.
# Packages are from https://dxr.mozilla.org/mozilla-central/source/python/mozboot/mozboot/debian.py
RUN sudo apt-get update -q \
 && sudo apt-get upgrade -qy \
 && sudo apt-get install -qy \
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
  libgtk-3-dev \
  libgtk2.0-dev \
  libiw-dev \
  libnotify-dev \
  libpulse-dev \
  libx11-xcb-dev \
  libxt-dev \
  mesa-common-dev \
  python-dbus \
  xvfb \
  yasm

# Download Thunderbird's source code.
RUN hg clone https://hg.mozilla.org/comm-central/ thunderbird \
 && cd thunderbird \
 && python client.py checkout
WORKDIR thunderbird

# Add Thunderbird build configuration.
ADD .mozconfig /home/user/thunderbird/
RUN sudo chown user:user /home/user/thunderbird/.mozconfig

# Set up Mercurial so mach doesn't complain.
RUN mkdir -p /home/user/.mozbuild \
 && ./mozilla/mach mercurial-setup -u

# Build Thunderbird.
RUN ./mozilla/mach build
