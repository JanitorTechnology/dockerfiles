FROM ubuntu:16.04

# Install HTTPS transport for Ubuntu package sources.
RUN apt-get update \
 && apt-get install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# Add source for the latest Clang packages.
COPY llvm-snapshot.gpg.key /tmp
RUN echo "deb https://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" > /etc/apt/sources.list.d/llvm.list \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && rm -f /tmp/llvm-snapshot.gpg.key

# Add source for the latest Git packages.
RUN add-apt-repository ppa:git-core/ppa

# Add source for the latest Mercurial packages.
RUN add-apt-repository ppa:mercurial-ppa/releases

# Add source for the latest Neovim packages.
RUN add-apt-repository ppa:neovim-ppa/stable

# Install basic development packages.
RUN __LLVM_VERSION__="7" \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  bash-completion \
  build-essential \
  ccache \
  clang-${__LLVM_VERSION__} \
  clang-tidy-${__LLVM_VERSION__} \
  cmake \
  curl \
  default-jdk \
  emacs \
  fluxbox \
  gdb \
  gettext \
  git \
  htop \
  icecc \
  iputils-ping \
  jq \
  less \
  libcurl4-openssl-dev \
  libexpat1-dev \
  libgl1-mesa-dev \
  libnotify-bin \
  libssl-dev \
  libtool \
  lld-${__LLVM_VERSION__} \
  lldb-${__LLVM_VERSION__} \
  locales \
  man \
  mercurial \
  nano \
  neovim \
  net-tools \
  openssh-server \
  php \
  php-curl \
  pkg-config \
  python-dev \
  python-pip \
  python-virtualenv \
  python-yaml \
  sudo \
  supervisor \
  tmux \
  unzip \
  valgrind \
  wget \
  x11vnc \
  xterm \
  xvfb \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /var/run/sshd \
 && pip install --no-cache-dir --upgrade pip==9.0.3 \
 && pip install --no-cache-dir --upgrade virtualenv \
 && pip install --no-cache-dir requests \
 && echo "SHELL=/bin/bash\nTERM=xterm-256color\nDISPLAY=:98\nCC=clang-${__LLVM_VERSION__}\nCXX=clang++-${__LLVM_VERSION__}\nHOST_CC=clang-${__LLVM_VERSION__}\nHOST_CXX=clang++-${__LLVM_VERSION__}" >> /etc/environment
ENV SHELL /bin/bash
ENV CC clang-7
ENV CXX clang++-7
ENV HOST_CC clang-7
ENV HOST_CXX clang++-7

# Disallow logging in to SSH with a password.
RUN sed -ri "s/^[#\s]*PasswordAuthentication\s+[yn].*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
 && sed -ri "s/^[#\s]*ChallengeResponseAuthentication\s+[yn].*$/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config

# Fix logging in to SSH on some platforms by disabling `pam_loginuid.so`.
# Source: https://gitlab.com/gitlab-org/gitlab-ce/issues/3027
RUN sed -ri "s/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/" /etc/pam.d/sshd

# Use a UTF-8 locale by default (instead of "POSIX").
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

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

# Configure bash prompt.
RUN echo "\n# Colored and git aware prompt." >> /home/user/.bashrc \
 && echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1 \" (%s)\") $ '" >> /home/user/.bashrc

# Install the latest GitHub helper.
RUN __HUB_VERSION__="2.6.0" \
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

# Install the latest nasm.
RUN __NASM_VERSION__="2.14.02" \
 && mkdir /tmp/nasm \
 && cd /tmp/nasm \
 && wget -qOnasm.tar.xz https://www.nasm.us/pub/nasm/releasebuilds/${__NASM_VERSION__}/nasm-${__NASM_VERSION__}.tar.xz \
 && tar xf nasm.tar.xz \
 && cd nasm-${__NASM_VERSION__}/ \
 && ./configure \
 && make \
 && sudo make install \
 && sudo rm -rf /tmp/nasm

# Install the latest watchman.
RUN git clone https://github.com/facebook/watchman.git /tmp/watchman \
 && cd /tmp/watchman \
 && git checkout v4.9.0 \
 && ./autogen.sh \
 && ./configure \
 && make -j`nproc` \
 && sudo make install \
 && sudo rm -rf /tmp/watchman

# Install the latest Node Version Manager.
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# Install latest Node.js, npm and Yarn.
ENV NVM_DIR="/home/user/.nvm"
RUN . $NVM_DIR/nvm.sh \
 && nvm install v10.13.0 \
 && npm install -g yarn
ENV PATH="${PATH}:${NVM_DIR}/versions/node/v10.13.0/bin"

# Install the latest rr.
RUN __RR_VERSION__="5.2.0" \
 && cd /tmp \
 && wget -qO rr.deb https://github.com/mozilla/rr/releases/download/${__RR_VERSION__}/rr-${__RR_VERSION__}-Linux-$(uname -m).deb \
 && sudo dpkg -i rr.deb \
 && rm -f rr.deb

# Install the latest Rust toolchains (stable and nightly).
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
 && echo "\n# Rust toolchain." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.cargo/bin\"" >> /home/user/.bashrc
ENV PATH="${PATH}:/home/user/.cargo/bin"
RUN rustup install nightly \
 && rustup completions bash | sudo tee /etc/bash_completion.d/rustup.bash-completion > /dev/null

# Install additional Rust components.
RUN rustup component add clippy rls-preview rustfmt-preview rust-analysis rust-src \
 && echo "RUST_SRC_PATH=\"/home/user/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src\"" >> /home/user/.bashrc

# Install the latest fd and ripgrep.
RUN cargo install fd-find \
 && cargo install ripgrep

# Install the latest z.
RUN git clone https://github.com/rupa/z /home/user/.z.sh \
 && echo "\n# Enable z (faster than cd)." >> /home/user/.bashrc \
 && echo ". /home/user/.z.sh/z.sh" >> /home/user/.bashrc

# Install the latest Vim.
RUN __VIM_VERSION__="8.1.0565" \
 && mkdir /tmp/vim \
 && cd /tmp/vim \
 && curl -L https://github.com/vim/vim/archive/v${__VIM_VERSION__}.tar.gz | tar xz \
 && cd vim-${__VIM_VERSION__}/src \
 && make -j`nproc` \
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
COPY --chown=user:user workspace-janitor.js /home/user/.c9sdk/configs/ide/

# Install the Theia IDE with all features available.
COPY --chown=user:user theia /home/user/.theia/
RUN cd /home/user/.theia/ \
 && yarn \
 && yarn theia build

# Configure language server executable for Theia.
ENV CPP_CLANGD_COMMAND clangd-7

# Add default Supervisor configuration.
COPY supervisord.conf /etc/

# Expose remote access ports.
EXPOSE 22 8087 8088 8089 8090

# Fallback workspace path for IDEs.
ENV WORKSPACE /home/user/

# Run all Supervisor services when the container starts.
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
