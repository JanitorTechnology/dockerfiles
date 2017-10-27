FROM janx/ubuntu-dev
MAINTAINER Jan Keromnes "janx@linux.com"

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update -q \
 && wget -O /tmp/bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py \
 && python /tmp/bootstrap.py --no-interactive --application-choice=browser \
 && rm -f /tmp/bootstrap.py

# Install Mozilla's moz-git-tools.
RUN git clone https://github.com/mozilla/moz-git-tools \
 && cd moz-git-tools \
 && git submodule init \
 && git submodule update
RUN echo "\n# Add Mozilla's moz-git-tools to the PATH." >> .bashrc \
 && echo "PATH=\"\$PATH:/home/user/moz-git-tools\"" >> .bashrc

# Download Firefox's source code.
RUN git clone https://github.com/mozilla/gecko-dev firefox
WORKDIR firefox

# Add Firefox build configuration.
ADD mozconfig /home/user/firefox/
RUN sudo chown user:user /home/user/firefox/mozconfig

# Set up Mercurial extensions for Firefox.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach mercurial-setup -u \
 && echo "\n# Add Mozilla's git commands to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.mozbuild/version-control-tools/git/commands\"" >> /home/user/.bashrc

# Configure Cloud9 to use Firefox's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/firefox/" /etc/supervisord.conf

# Build Firefox.
RUN ./mach build

# Configure Janitor for Firefox
ADD janitor-git.json /home/user/janitor.json
RUN sudo chown user:user /home/user/janitor.json
