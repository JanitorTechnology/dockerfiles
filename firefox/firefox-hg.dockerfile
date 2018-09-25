FROM janitortechnology/ubuntu-dev

# Download Firefox's source code.
RUN hg clone --uncompressed https://hg.mozilla.org/mozilla-unified/ firefox \
 && cd firefox \
 && hg update central
WORKDIR firefox

# Add Firefox build configuration.
COPY --chown=user:user mozconfig /home/user/firefox/

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update \
 && python python/mozboot/bin/bootstrap.py --no-interactive --application-choice=browser \
 && sudo rm -rf /var/lib/apt/lists/*

# Set up Mercurial extensions for Firefox.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach vcs-setup -u

# Install moz-phab to support uploading multiple commits to Phabricator.
RUN git clone https://github.com/mozilla-conduit/review/ /home/user/.moz-phab \
 && echo "\n# Add moz-phab to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.moz-phab\"" >> /home/user/.bashrc

# Configure the IDEs to use Firefox's source directory as workspace.
ENV WORKSPACE /home/user/firefox/

# Build Firefox.
RUN ./mach build

# Configure Janitor for Firefox
COPY --chown=user:user janitor-hg.json /home/user/janitor.json
