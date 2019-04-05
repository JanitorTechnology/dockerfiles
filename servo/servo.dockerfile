FROM janitortechnology/ubuntu-dev

# Install Servo build dependencies.
# Packages are from https://github.com/servo/servo/blob/master/README.md#on-debian-based-linuxes
# and https://github.com/servo/servo/issues/7512#issuecomment-216665988
RUN sudo apt-get update \
 && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
  autoconf2.13 \
  xserver-xorg-input-void \
  xserver-xorg-video-dummy \
  xpra \
  libunwind-dev \
  liblzma-dev \
 && sudo rm -rf /var/lib/apt/lists/*

# Help clang-sys find LLVM.
# See https://github.com/servo/servo/issues/22384#issuecomment-453240318
ENV CLANG_BASE /usr/lib/llvm-7/lib/

# Enable required Xvfb extensions for Servo.
# Source: https://github.com/servo/servo/issues/7512#issuecomment-216665988
RUN sudo sed -i "s/\(Xvfb :.*\)$/\1 +extension RANDR +extension RENDER +extension GLX/" /etc/supervisord.conf

# Download Servo's source code.
RUN git clone https://github.com/servo/servo
WORKDIR servo

# Configure the IDEs to use Servo's source directory as workspace.
ENV WORKSPACE /home/user/servo/

# Work around a Servo build problem.
RUN echo "\n# Work around https://github.com/servo/servo/issues/20712." >> /home/user/.bashrc \
 && echo "export HARFBUZZ_SYS_NO_PKG_CONFIG=1" >> /home/user/.bashrc
ENV HARFBUZZ_SYS_NO_PKG_CONFIG 1

# Install a more recent GStreamer.
RUN ./mach bootstrap-gstreamer

# Build Servo.
RUN ./mach build -d

# Configure Janitor for Servo
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
