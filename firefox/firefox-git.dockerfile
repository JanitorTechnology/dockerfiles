FROM janitortechnology/ubuntu-dev

# Install Mozilla's moz-git-tools.
RUN git clone https://github.com/mozilla/moz-git-tools /home/user/.moz-git-tools \
 && cd /home/user/.moz-git-tools \
 && git submodule init \
 && git submodule update
RUN echo "\n# Add Mozilla's moz-git-tools to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.moz-git-tools\"" >> /home/user/.bashrc

# Install git-cinnabar.
RUN git clone https://github.com/glandium/git-cinnabar /home/user/.git-cinnabar \
 && /home/user/.git-cinnabar/git-cinnabar download \
 && echo "\n# Add git-cinnabar to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.git-cinnabar\"" >> /home/user/.bashrc
ENV PATH $PATH:/home/user/.git-cinnabar

# Download Firefox's source code.
RUN git clone https://github.com/mozilla/gecko-dev /home/user/firefox
WORKDIR /home/user/firefox

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
 && ./mach vcs-setup -u \
 && echo "\n# Add Mozilla's git commands to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.mozbuild/version-control-tools/git/commands\"" >> /home/user/.bashrc

# Configure the IDEs to use Firefox's source directory as workspace.
ENV WORKSPACE /home/user/firefox/

# Build Firefox.
RUN ./mach build

# Configure Janitor for Firefox
COPY --chown=user:user janitor-git.json /home/user/janitor.json
