FROM ubuntu:14.04
MAINTAINER Jan Keromnes "janx@linux.com"

# Install Chromium build dependencies.
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list # && dpkg --add-architecture i386
RUN apt-get update && apt-get install -qy git build-essential clang curl
RUN curl -L https://src.chromium.org/chrome/trunk/src/build/install-build-deps.sh > /tmp/install-build-deps.sh
RUN chmod +x /tmp/install-build-deps.sh
RUN /tmp/install-build-deps.sh --no-prompt --no-arm --no-chromeos-fonts --no-nacl
RUN rm /tmp/install-build-deps.sh

# Don't build as root.
RUN useradd -m user
USER user
ENV HOME /home/user
WORKDIR /home/user

# Install Chromium's depot_tools.
ENV DEPOT_TOOLS /home/user/depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS
ENV PATH $PATH:$DEPOT_TOOLS
RUN echo -e "\n# Add Chromium's depot_tools to the PATH." >> .bashrc
RUN echo "export PATH=\"\$PATH:$DEPOT_TOOLS\"" >> .bashrc

# Download Chromium sources.
RUN fetch chromium --nosvn=True
WORKDIR src

# Build Chromium
RUN ninja -C out/Release chrome -j18
