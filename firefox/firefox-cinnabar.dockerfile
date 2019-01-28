FROM janitortechnology/ubuntu-dev

# Install git-cinnabar.
RUN git clone https://github.com/glandium/git-cinnabar /home/user/.git-cinnabar \
 && /home/user/.git-cinnabar/git-cinnabar download \
 && echo "\n# Add git-cinnabar to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.git-cinnabar\"" >> /home/user/.bashrc
ENV PATH $PATH:/home/user/.git-cinnabar

# Download Firefox's source code using git-cinnabar.
# Source: https://github.com/glandium/git-cinnabar/wiki/Mozilla:-A-git-workflow-for-Gecko-development
RUN git -c cinnabar.clone=https://github.com/glandium/gecko clone hg::https://hg.mozilla.org/mozilla-unified /home/user/firefox \
 && cd /home/user/firefox \
 && git config fetch.prune true \
 && git remote add try hg::https://hg.mozilla.org/try \
 && git config remote.try.skipDefaultUpdate true \
 && git remote set-url --push try hg::ssh://hg.mozilla.org/try \
 && git config remote.try.push +HEAD:refs/heads/branches/default/tip \
 && git remote add inbound hg::ssh://hg.mozilla.org/integration/mozilla-inbound \
 && git config remote.inbound.skipDefaultUpdate true \
 && git config remote.inbound.push +HEAD:refs/heads/branches/default/tip \
 && git fetch --tags hg::tags: tag "*"
WORKDIR /home/user/firefox

# Add Firefox build configuration.
COPY --chown=user:user mozconfig /home/user/firefox/

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update \
 && python python/mozboot/bin/bootstrap.py --no-interactive --application-choice=browser \
 && sudo rm -rf /var/lib/apt/lists/*

# Set up VCS extensions for Firefox.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach vcs-setup -u \
 && echo "\n# Add Mozilla's Git commands to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.mozbuild/version-control-tools/git/commands\"" >> /home/user/.bashrc

# Install Phlay to support uploading multiple commits to Phabricator.
RUN git clone https://github.com/mystor/phlay/ /home/user/.phlay \
 && echo "\n# Add Phlay to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.phlay\"" >> /home/user/.bashrc

# Also install moz-phab to support uploading multiple commits to Phabricator.
RUN git clone https://github.com/mozilla-conduit/review/ /home/user/.moz-phab \
 && echo "\n# Add moz-phab to the PATH." >> /home/user/.bashrc \
 && echo "PATH=\"\$PATH:/home/user/.moz-phab\"" >> /home/user/.bashrc

# Configure the IDEs to use Firefox's source directory as workspace.
ENV WORKSPACE /home/user/firefox/

# Build Firefox.
RUN ./mach build

# Configure Janitor for Firefox
COPY --chown=user:user janitor-cinnabar.json /home/user/janitor.json
