FROM janx/ubuntu-dev
MAINTAINER Philipp Kewisch "mozilla@kewis.ch"

# Install Firefox build dependencies.
# One-line setup command from:
# https://developer.mozilla.org/en-US/docs/Mozilla/Developer_guide/Build_Instructions/Linux_Prerequisites#Most_Distros_-_One_Line_Bootstrap_Command
RUN sudo apt-get update -q \
 && wget -O /tmp/bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py \
 && python /tmp/bootstrap.py --no-interactive --application-choice=browser \
 && rm -f /tmp/bootstrap.py

# Download Thunderbird's source code.
RUN hg clone --uncompressed https://hg.mozilla.org/comm-central/ thunderbird \
 && cd thunderbird \
 && python client.py checkout
WORKDIR thunderbird

# Add Thunderbird build configuration.
ADD .mozconfig /home/user/thunderbird/
RUN sudo chown user:user /home/user/thunderbird/.mozconfig

# Set up Mercurial so mach doesn't complain.
RUN mkdir -p /home/user/.mozbuild \
 && ./mozilla/mach mercurial-setup -u

# Configure Cloud9 to use Thunderbird's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/thunderbird/" /etc/supervisord.conf

# Build Thunderbird.
RUN ./mozilla/mach build

# Configure Janitor for Thunderbird
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
