FROM janitortechnology/ubuntu-dev
MAINTAINER Philipp Kewisch "mozilla@kewis.ch"

# Download Thunderbird's source code.
RUN hg clone --uncompressed https://hg.mozilla.org/mozilla-central/ thunderbird \
 && hg clone --uncompressed https://hg.mozilla.org/comm-central/ thunderbird/comm
WORKDIR thunderbird

# Add Thunderbird build configuration.
ADD .mozconfig /home/user/thunderbird/
RUN sudo chown user:user /home/user/thunderbird/.mozconfig

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update \
 && python python/mozboot/bin/bootstrap.py --no-interactive --application-choice=browser \
 && sudo rm -rf /var/lib/apt/lists/*

# Set up Mercurial so mach doesn't complain.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach vcs-setup -u

# Configure the IDEs to use Thunderbird's source directory as workspace.
ENV WORKSPACE /home/user/thunderbird/

# Build Thunderbird.
RUN ./mach build

# Configure Janitor for Thunderbird
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
