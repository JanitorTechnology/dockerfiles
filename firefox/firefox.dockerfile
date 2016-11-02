FROM janx/ubuntu-dev
MAINTAINER Jan Keromnes "janx@linux.com"

# Install Firefox build dependencies.
# Packages after "mercurial" are from https://dxr.mozilla.org/mozilla-central/source/python/mozboot/mozboot/debian.py
RUN sudo apt-get update -q \
 && sudo apt-get upgrade -qy \
 && sudo apt-get install -qy \
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

# Install Mozilla's moz-git-tools.
RUN pip install requests
RUN git clone https://github.com/mozilla/moz-git-tools \
 && cd moz-git-tools \
 && git submodule init \
 && git submodule update
ENV PATH $PATH:/home/user/moz-git-tools
RUN echo "\n# Add Mozilla's moz-git-tools to the PATH." >> .bashrc \
 && echo "export PATH=\"\$PATH:/home/user/moz-git-tools\"" >> .bashrc

# Download Firefox's source code.
RUN git clone https://github.com/mozilla/gecko-dev firefox
#RUN hg clone https://hg.mozilla.org/mozilla-central/ firefox
WORKDIR firefox

# Add Firefox build configuration.
ADD mozconfig /home/user/firefox/

# Set up Mercurial extensions for Firefox.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach mercurial-setup -u

# Build Firefox.
RUN ./mach build
