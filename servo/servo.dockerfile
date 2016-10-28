FROM janx/ubuntu-dev
MAINTAINER Jan Keromnes "janx@linux.com"

# Install Servo build dependencies.
# Packages are from https://github.com/servo/servo/blob/master/README.md#prerequisites
# and https://github.com/servo/servo/issues/7512#issuecomment-216665988
RUN sudo apt-get update -q \
 && sudo apt-get upgrade -qy \
 && sudo DEBIAN_FRONTEND=noninteractive apt-get install -qy \
  freeglut3-dev \
  autoconf \
  libfreetype6-dev \
  libgl1-mesa-dri \
  libglib2.0-dev \
  xorg-dev \
  gperf \
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
  xserver-xorg-input-void \
  xserver-xorg-video-dummy \
  xpra

# Sadly, Servo can't be built with clang yet.
ENV CC gcc
ENV CXX g++

# Enable required Xvfb extensions for Servo.
# Source: https://github.com/servo/servo/issues/7512#issuecomment-216665988
RUN sudo sed -i "s/\(Xvfb :.*\)$/\1 +extension RANDR +extension RENDER +extension GLX/" /etc/supervisord.conf

# Download Servo's source code.
RUN git clone https://github.com/servo/servo
WORKDIR servo

# Build Servo.
RUN ./mach build -d
