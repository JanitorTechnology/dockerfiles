FROM ubuntu:16.04
MAINTAINER Jan Keromnes "janx@linux.com"

# Add source for the latest Clang packages.
ADD llvm-snapshot.gpg.key /tmp
RUN echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.9 main" >> /etc/apt/sources.list.d/llvm.list \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && rm -f /tmp/llvm-snapshot.gpg.key

# Enable extended "multiverse" Ubuntu packages.
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial multiverse" >> /etc/apt/sources.list

# Install basic development packages.
RUN apt-get update -q \
 && apt-get upgrade -qy \
 && apt-get install -qy \
  asciidoc \
  build-essential \
  clang-3.9 \
  cmake \
  curl \
  emacs \
  fluxbox \
  gdb \
  gettext \
  less \
  libcurl4-openssl-dev \
  libexpat1-dev \
  libssl-dev \
  net-tools \
  ninja-build \
  openssh-server \
  sudo \
  supervisor \
  x11vnc \
  xvfb \
 && mkdir /var/run/sshd
ENV SHELL /bin/bash
ENV CC clang-3.9
ENV CXX clang++-3.9

# Add default Supervisor configuration.
ADD supervisord.conf /etc/

# Disallow logging in to SSH with a password.
RUN sed -i "s/^[#\s]*PasswordAuthentication\s+[yn].*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
 && sed -i "s/^[#\s]*ChallengeResponseAuthentication\s+[yn].*$/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config

# Add a user that can `sudo`.
RUN useradd -m user \
 && echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/user

# Don't be root.
USER user
ENV HOME /home/user
WORKDIR /home/user

# Install the latest Git.
RUN mkdir /tmp/git \
 && cd /tmp/git \
 && curl https://www.kernel.org/pub/software/scm/git/git-2.11.1.tar.xz | tar xJ \
 && cd git-2.11.1 \
 && make prefix=/usr profile man -j18 \
 && sudo make prefix=/usr PROFILE=BUILD install install-man -j18 \
 && rm -rf /tmp/git

# Install the latest GitHub helper.
RUN mkdir /tmp/hub \
 && cd /tmp/hub \
 && curl -L https://github.com/github/hub/releases/download/v2.2.9/hub-linux-amd64-2.2.9.tgz | tar xz \
 && cd hub-linux-amd64-2.2.9 \
 && sudo ./install \
 && rm -rf /tmp/hub

# Install the latest Node.js and npm.
# Non-sudo global packages: https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
RUN git clone https://github.com/nodejs/node /tmp/node \
 && cd /tmp/node \
 && git checkout v7.5.0 \
 && ./configure \
 && make -j18 \
 && sudo make install \
 && rm -rf /tmp/node \
 && mkdir /home/user/.npm-packages \
 && echo "prefix=/home/user/.npm-packages" >> /home/user/.npmrc \
 && echo "\n# NPM configuration." >> /home/user/.bashrc \
 && echo "NPM_PACKAGES=\"/home/user/.npm-packages\"" >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:\$NPM_PACKAGES/bin\"" >> /home/user/.bashrc

# Install the latest rr.
RUN cd /tmp \
 && wget https://github.com/mozilla/rr/releases/download/4.5.0/rr-4.5.0-Linux-$(uname -m).deb -O rr.deb \
 && sudo dpkg -i rr.deb \
 && rm -f rr.deb

# Install the latest Rust toolchain.
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
 && echo "\n# Rust toolchain." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.cargo/bin\"" >> /home/user/.bashrc
ENV PATH="${PATH}:/home/user/.cargo/bin"
RUN rustup completions bash | sudo tee /etc/bash_completion.d/rustup.bash-completion

# Install the latest Vim.
RUN mkdir /tmp/vim \
 && cd /tmp/vim \
 && curl -L https://github.com/vim/vim/archive/v8.0.0311.tar.gz | tar xz \
 && cd vim-8.0.0311/src \
 && make -j18 \
 && sudo make install \
 && rm -rf /tmp/vim \
 && echo "\n# EDITOR configuration.\nEDITOR=vim" >> /home/user/.bashrc
ENV EDITOR vim

# Install Cloud9 and noVNC.
RUN curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash
RUN git clone https://github.com/kanaka/noVNC /home/user/.novnc/

# Expose remote access ports.
EXPOSE 22 8088

# Run all Supervisor services when the container starts.
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
