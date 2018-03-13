FROM janitortechnology/ubuntu-dev
MAINTAINER Jan Keromnes "janx@linux.com"

# Install Servo build dependencies.
# Packages are from https://github.com/servo/servo/blob/master/README.md#on-debian-based-linuxes
# and https://github.com/servo/servo/issues/7512#issuecomment-216665988
RUN sudo apt-get update \
 && sudo apt-get install -y --no-install-recommends \
  git \
  curl \
  autoconf \
  libx11-dev \
  libfreetype6-dev \
  libgl1-mesa-dri \
  libglib2.0-dev \
  xorg-dev \
  gperf \
  g++ \
  build-essential \
  cmake \
  python-virtualenv \
  python-pip \
  libssl-dev \
  libbz2-dev \
  libosmesa6-dev \
  libxmu6 \
  libxmu-dev \
  libglu1-mesa-dev \
  libgles2-mesa-dev \
  libegl1-mesa-dev \
  libdbus-1-dev \
  libharfbuzz-dev \
  ccache \
  xserver-xorg-input-void \
  xserver-xorg-video-dummy \
  xpra \
 && sudo rm -rf /var/lib/apt/lists/*

# Sadly, Servo can't be built with Clang yet.
ENV CC gcc
ENV CXX g++
RUN sudo sed -i "s/CC=clang-5\.0/CC=gcc/" /etc/environment \
 && sudo sed -i "s/CXX=clang++-5\.0/CXX=g++/" /etc/environment

# Enable required Xvfb extensions for Servo.
# Source: https://github.com/servo/servo/issues/7512#issuecomment-216665988
RUN sudo sed -i "s/\(Xvfb :.*\)$/\1 +extension RANDR +extension RENDER +extension GLX/" /etc/supervisord.conf

# Download Servo's source code.
RUN git clone https://github.com/servo/servo
WORKDIR servo

# Configure the IDEs to use Servo's source directory as workspace.
ENV WORKSPACE /home/user/servo/

# Build Servo.
RUN ./mach build -d

# Configure Janitor for Servo
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
