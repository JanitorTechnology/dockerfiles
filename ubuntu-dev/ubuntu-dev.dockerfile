FROM ubuntu:16.04
MAINTAINER Jan Keromnes "janx@linux.com"

# Add source for the latest Clang packages.
ADD llvm-snapshot.gpg.key /tmp
RUN echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main" > /etc/apt/sources.list.d/llvm.list \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && rm -f /tmp/llvm-snapshot.gpg.key

# Add source for the latest Mercurial packages.
RUN echo "deb http://ppa.launchpad.net/mercurial-ppa/releases/ubuntu xenial main" > /etc/apt/sources.list.d/mercurial.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 41BD8711B1F0EC2B0D85B91CF59CE3A8323293EE

# Enable extended "multiverse" Ubuntu packages.
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial multiverse" >> /etc/apt/sources.list

# Install basic development packages.
RUN apt-get update -q \
 && apt-get upgrade -qy \
 && apt-get install -qy \
  asciidoc \
  build-essential \
  ccache \
  clang-4.0 \
  cmake \
  curl \
  emacs \
  fluxbox \
  gdb \
  gettext \
  htop \
  less \
  libcurl4-openssl-dev \
  libexpat1-dev \
  libgl1-mesa-dev \
  libnotify-bin \
  libssl-dev \
  lld-4.0 \
  mercurial \
  nano \
  net-tools \
  ninja-build \
  openssh-server \
  php \
  php-curl \
  sudo \
  supervisor \
  x11vnc \
  xvfb \
 && mkdir /var/run/sshd \
 && echo "SHELL=/bin/bash\nTERM=xterm-256color\nCC=clang-4.0\nCXX=clang++-4.0" >> /etc/environment
ENV SHELL /bin/bash
ENV CC clang-4.0
ENV CXX clang++-4.0

# Add default Supervisor configuration.
ADD supervisord.conf /etc/

# Disallow logging in to SSH with a password.
RUN sed -i "s/^[#\s]*PasswordAuthentication\s+[yn].*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
 && sed -i "s/^[#\s]*ChallengeResponseAuthentication\s+[yn].*$/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config

# Fix logging in to SSH on some platforms by disabling `pam_loginuid.so`.
# Source: https://gitlab.com/gitlab-org/gitlab-ce/issues/3027
RUN sed -ri "s/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/" /etc/pam.d/sshd

# Add a user that can `sudo`.
RUN useradd --create-home --shell /bin/bash user \
 && echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/user

# Don't be root.
USER user
ENV HOME /home/user
WORKDIR /home/user

# Configure SSH to use Bash with colors by default.
RUN mkdir /home/user/.ssh \
 && touch /home/user/.ssh/authorized_keys \
 && touch /home/user/.ssh/config \
 && echo "SHELL=/bin/bash\nTERM=xterm-256color" >> /home/user/.ssh/environment \
 && chmod 700 /home/user/.ssh \
 && chmod 600 /home/user/.ssh/*

# Configure ccache with enough disk space to save large builds.
RUN mkdir /home/user/.ccache \
 && echo "max_size = 10G" > /home/user/.ccache/ccache.conf

# Install the latest Git.
RUN mkdir /tmp/git \
 && cd /tmp/git \
 && curl https://www.kernel.org/pub/software/scm/git/git-2.13.0.tar.xz | tar xJ \
 && cd git-2.13.0 \
 && make prefix=/usr profile man -j18 \
 && sudo make prefix=/usr PROFILE=BUILD install install-man -j18 \
 && cp contrib/completion/git-completion.bash /home/user/.git-completion.bash \
 && cp contrib/completion/git-prompt.sh /home/user/.git-prompt.sh \
 && echo "\n# Git completion helpers." >> /home/user/.bashrc \
 && echo "source /home/user/.git-completion.bash" >> /home/user/.bashrc \
 && echo "source /home/user/.git-prompt.sh" >> /home/user/.bashrc \
 && echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1 \" (%s)\") $ '" >> /home/user/.bashrc \
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
 && git checkout v7.10.0 \
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

# Install the latest ripgrep.
RUN cargo install ripgrep

# Install the latest z.
RUN git clone https://github.com/rupa/z /home/user/.z.sh \
 && echo "\n# Enable z (faster than cd)." >> /home/user/.bashrc \
 && echo ". /home/user/.z.sh/z.sh" >> /home/user/.bashrc

# Install the latest Vim.
RUN mkdir /tmp/vim \
 && cd /tmp/vim \
 && curl -L https://github.com/vim/vim/archive/v8.0.0596.tar.gz | tar xz \
 && cd vim-8.0.0596/src \
 && make -j18 \
 && sudo make install \
 && rm -rf /tmp/vim \
 && echo "\n# Make Vim the default editor.\nEDITOR=vim" >> /home/user/.bashrc
ENV EDITOR vim

# Install the latest Phabricator helper.
RUN mkdir /home/user/.phacility \
 && cd /home/user/.phacility \
 && git clone https://github.com/phacility/libphutil \
 && git clone https://github.com/phacility/arcanist \
 && echo "\n# Phabricator helper." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.phacility/arcanist/bin\"" >> /home/user/.bashrc

# Install Cloud9 and noVNC.
RUN git clone https://github.com/c9/core.git /home/user/.c9sdk \
 && cd /home/user/.c9sdk \
 && ./scripts/install-sdk.sh \
 && npm install -g c9
RUN git clone https://github.com/kanaka/noVNC /home/user/.novnc/ \
 && cd /home/user/.novnc \
 && npm update

# Expose remote access ports.
EXPOSE 22 8088 8089

# Run all Supervisor services when the container starts.
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
