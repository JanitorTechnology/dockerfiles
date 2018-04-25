FROM janitortechnology/ubuntu-dev

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update \
 && wget -O /tmp/bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py \
 && python /tmp/bootstrap.py --no-interactive --application-choice=browser \
 && rm -f /tmp/bootstrap.py \
 && sudo rm -rf /var/lib/apt/lists/*

# Download Firefox's source code.
RUN hg clone --uncompressed https://hg.mozilla.org/mozilla-unified/ firefox \
 && cd firefox \
 && hg update central
WORKDIR firefox

# Add Firefox build configuration.
COPY --chown=user:user mozconfig /home/user/firefox/

# Set up Mercurial extensions for Firefox.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach mercurial-setup -u

# Configure the IDEs to use Firefox's source directory as workspace.
ENV WORKSPACE /home/user/firefox/

# Build Firefox.
RUN ./mach build

# Configure Janitor for Firefox
COPY --chown=user:user janitor-hg.json /home/user/janitor.json
