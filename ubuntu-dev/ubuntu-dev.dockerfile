FROM ubuntu:16.04
MAINTAINER Jan Keromnes "janx@linux.com"

# Install HTTPS transport for Ubuntu package sources.
RUN apt-get update -q \
 && apt-get install -qy apt-transport-https

# Add source for the latest Clang packages.
ADD llvm-snapshot.gpg.key /tmp
RUN echo "deb https://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main" > /etc/apt/sources.list.d/llvm.list \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && rm -f /tmp/llvm-snapshot.gpg.key

# Add source for the latest Mercurial packages.
RUN echo "deb http://ppa.launchpad.net/mercurial-ppa/releases/ubuntu xenial main" > /etc/apt/sources.list.d/mercurial.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 41BD8711B1F0EC2B0D85B91CF59CE3A8323293EE

# Add source for the latest Neovim packages.
RUN echo "deb http://ppa.launchpad.net/neovim-ppa/stable/ubuntu xenial main" > /etc/apt/sources.list.d/neovim.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9DBB0BE9366964F134855E2255F96FCF8231B6DD

# Install basic development packages.
RUN __LLVM_VERSION__="5.0" \
 && apt-get update -q \
 && apt-get upgrade -qy \
 && apt-get install -qy \
  asciidoc \
  build-essential \
  ccache \
  clang-${__LLVM_VERSION__} \
  clang-tidy-${__LLVM_VERSION__} \
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
  lld-${__LLVM_VERSION__} \
  locales \
  man \
  mercurial \
  nano \
  neovim \
  net-tools \
  openssh-server \
  php \
  php-curl \
  python-pip \
  python-virtualenv \
  sudo \
  supervisor \
  tmux \
  valgrind \
  x11vnc \
  xvfb \
 && mkdir /var/run/sshd \
 && pip install --upgrade pip \
 && pip install --upgrade virtualenv \
 && pip install requests \
 && echo "SHELL=/bin/bash\nTERM=xterm-256color\nDISPLAY=:98\nCC=clang-${__LLVM_VERSION__}\nCXX=clang++-${__LLVM_VERSION__}" >> /etc/environment
ENV SHELL /bin/bash
ENV CC clang-5.0
ENV CXX clang++-5.0

# Disallow logging in to SSH with a password.
RUN sed -ri "s/^[#\s]*PasswordAuthentication\s+[yn].*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
 && sed -ri "s/^[#\s]*ChallengeResponseAuthentication\s+[yn].*$/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config

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
RUN __GIT_VERSION__="2.15.1" \
 && mkdir /tmp/git \
 && cd /tmp/git \
 && curl https://www.kernel.org/pub/software/scm/git/git-${__GIT_VERSION__}.tar.xz | tar xJ \
 && cd git-${__GIT_VERSION__} \
 && make prefix=/usr all man -j18 \
 && sudo make prefix=/usr install install-man -j18 \
 && cp contrib/completion/git-completion.bash /home/user/.git-completion.bash \
 && cp contrib/completion/git-prompt.sh /home/user/.git-prompt.sh \
 && echo "\n# Git completion helpers." >> /home/user/.bashrc \
 && echo "source /home/user/.git-completion.bash" >> /home/user/.bashrc \
 && echo "source /home/user/.git-prompt.sh" >> /home/user/.bashrc \
 && echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1 \" (%s)\") $ '" >> /home/user/.bashrc \
 && rm -rf /tmp/git

# Install the latest GitHub helper.
RUN __HUB_VERSION__="2.2.9" \
 && mkdir /tmp/hub \
 && cd /tmp/hub \
 && curl -L https://github.com/github/hub/releases/download/v${__HUB_VERSION__}/hub-linux-amd64-${__HUB_VERSION__}.tgz | tar xz \
 && cd hub-linux-amd64-${__HUB_VERSION__} \
 && sudo ./install \
 && rm -rf /tmp/hub

# Install the latest Ninja.
RUN git clone https://github.com/ninja-build/ninja /tmp/ninja \
 && cd /tmp/ninja \
 && git checkout v1.8.2 \
 && ./configure.py --bootstrap \
 && sudo mv ninja /usr/bin/ninja \
 && mv misc/bash-completion /home/user/.ninja-bash-completion \
 && mv misc/zsh-completion /home/user/.ninja-zsh-completion \
 && echo "\n# Ninja completion helpers." >> /home/user/.bashrc \
 && echo ". /home/user/.ninja-bash-completion" >> /home/user/.bashrc \
 && rm -rf /tmp/ninja

# Install the latest Node Version Manager.
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# Install latest Node.js, npm and Yarn.
ENV NVM_DIR="/home/user/.nvm"
RUN . $NVM_DIR/nvm.sh \
 && nvm install v8.9.4 \
 && npm install -g yarn
ENV PATH="${PATH}:${NVM_DIR}/versions/node/v8.9.4/bin"

# Install the latest rr.
RUN __RR_VERSION__="5.1.0" \
 && cd /tmp \
 && wget https://github.com/mozilla/rr/releases/download/${__RR_VERSION__}/rr-${__RR_VERSION__}-Linux-$(uname -m).deb -O rr.deb \
 && sudo dpkg -i rr.deb \
 && rm -f rr.deb

# Install the latest Rust toolchains (stable and nightly).
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
 && echo "\n# Rust toolchain." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.cargo/bin\"" >> /home/user/.bashrc
ENV PATH="${PATH}:/home/user/.cargo/bin"
RUN rustup install nightly \
 && rustup completions bash | sudo tee /etc/bash_completion.d/rustup.bash-completion

# Install the latest Rust Language Server.
RUN rustup component add rls-preview \
 && rustup component add rust-analysis \
 && rustup component add rust-src \
 && echo "RUST_SRC_PATH=\"/home/user/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src\"" >> /home/user/.bashrc

# Install the latest ripgrep, rustfmt and clippy.
RUN cargo install ripgrep \
 && cargo install rustfmt --force \
 && cargo +nightly install clippy

# Install the latest z.
RUN git clone https://github.com/rupa/z /home/user/.z.sh \
 && echo "\n# Enable z (faster than cd)." >> /home/user/.bashrc \
 && echo ". /home/user/.z.sh/z.sh" >> /home/user/.bashrc

# Install the latest Vim.
RUN __VIM_VERSION__="8.0.1428" \
 && mkdir /tmp/vim \
 && cd /tmp/vim \
 && curl -L https://github.com/vim/vim/archive/v${__VIM_VERSION__}.tar.gz | tar xz \
 && cd vim-${__VIM_VERSION__}/src \
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

# Install the latest web-terminal.
RUN npm install web-terminal -g

# Install the latest noVNC.
RUN git clone https://github.com/kanaka/noVNC /home/user/.novnc/ \
 && cd /home/user/.novnc \
 && npm install \
 && node ./utils/use_require.js --as commonjs --with-app

# Install the latest Cloud9 SDK with some useful IDE plugins.
RUN git clone https://github.com/c9/core.git /home/user/.c9sdk \
 && cd /home/user/.c9sdk/plugins \
 && git clone https://github.com/JanitorTechnology/c9.ide.janitorconfig \
 && git clone https://github.com/nt1m/c9.ide.reviewcomments \
 && cd /home/user/.c9sdk \
 && ./scripts/install-sdk.sh \
 && git checkout -- node_modules \
 && npm install -g c9
ADD workspace-janitor.js /home/user/.c9sdk/configs/ide/
RUN sudo chown user:user /home/user/.c9sdk/configs/ide/workspace-janitor.js

# Add default Supervisor configuration.
ADD supervisord.conf /etc/

# Expose remote access ports.
EXPOSE 22 8087 8088 8089

# Run all Supervisor services when the container starts.
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
