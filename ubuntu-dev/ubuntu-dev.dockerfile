FROM ubuntu:16.04
MAINTAINER Jan Keromnes "janx@linux.com"

# Install basic development packages, and build dependencies for Git and Cloud9.
RUN apt-get update -q \
 && apt-get upgrade -qy \
 && apt-get install -qy \
  asciidoc \
  build-essential \
  curl \
  emacs \
  fluxbox \
  gdb \
  gettext \
  libcurl4-openssl-dev \
  libexpat1-dev \
  libssl-dev \
  net-tools \
  openssh-server \
  sudo \
  supervisor \
  vim \
  x11vnc \
  xvfb \
 && mkdir /var/run/sshd

# Disallow logging in to SSH with a password.
RUN sed -i "s/^[#\s]*PasswordAuthentication\s.*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
 && sed -i "s/^[#\s]*ChallengeResponseAuthentication\s.*$/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config

# Add a user that can `sudo`.
RUN useradd -m user \
 && echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/user
ENV HOME /home/user
WORKDIR /home/user

# Install the latest Git. TODO: profile-install
RUN mkdir /tmp/git \
 && cd /tmp/git \
 && curl https://www.kernel.org/pub/software/scm/git/git-2.8.1.tar.xz | tar xf \
 && make prefix=/usr install install-man -j18 \
 && rm -rf /tmp/git

# Install the latest Node.js and npm.
# Non-sudo global packages: https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
RUN git clone https://github.com/nodejs/node /tmp/node \
 && cd /tmp/node \
 && git checkout v6.0.0 \
 && ./configure \
 && make -j18 \
 && make install \
 && rm -rf /tmp/node \
 && mkdir /home/user/.npm-packages \
 && echo "prefix=/home/user/.npm-packages" >> /home/user/.npmrc \
 && chown -R user:user /home/user/.npm-packages /home/user/.npmrc \
 && echo "\n# NPM configuration." >> /home/user/.bashrc \
 && echo "NPM_PACKAGES=\"/home/user/.npm-packages\"" >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:\$NPM_PACKAGES/bin\"" >> /home/user/.bashrc

# Install Cloud9 and noVNC (without administrator privileges).
USER user
WORKDIR /home/user
RUN curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash
RUN git clone https://github.com/kanaka/noVNC /home/user/.novnc/
USER root

# Add default Supervisor configuration.
ADD supervisord.conf /etc/

# Expose remote access ports.
EXPOSE 22 8088

# Run all Supervisor services when the container starts.
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
