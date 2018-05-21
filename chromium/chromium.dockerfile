FROM janitortechnology/ubuntu-dev

# Install Chromium's depot_tools.
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH $PATH:/home/user/depot_tools
RUN echo "\n# Add Chromium's depot_tools to the PATH." >> .bashrc \
 && echo "export PATH=\"\$PATH:/home/user/depot_tools\"" >> .bashrc \

# Make default Ninja parallelism use 8 parallel jobs.
RUN echo "\nalias ninja='ninja -j8'" >> .bash_aliases

# Enable bash completion for git cl.
RUN echo "\n# The next line enables bash completion for git cl." >> .bashrc \
 && echo "if [ -f \"/home/user/depot_tools/git_cl_completion.sh\" ]; then" >> .bashrc \
 && echo "  . \"/home/user/depot_tools/git_cl_completion.sh\"" >> .bashrc \
 && echo "fi" >> .bashrc

# Disable gyp_chromium for faster updates.
ENV GYP_CHROMIUM_NO_ACTION 1
RUN echo "\n# Disable gyp_chromium for faster updates." >> .bashrc \
 && echo "export GYP_CHROMIUM_NO_ACTION=1" >> .bashrc

# Create the Chromium directory.
RUN mkdir /home/user/chromium
WORKDIR /home/user/chromium

# Download Chromium's source code.
RUN fetch --nohooks chromium

# Install Chromium build dependencies (with administrator privileges).
RUN sudo apt update \
 && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections \
 && sudo src/build/install-build-deps.sh --no-prompt --no-arm --no-chromeos-fonts --no-nacl \
 && sudo rm -rf /var/lib/apt/lists/*
RUN cd /tmp \
 && wget -q https://launchpad.net/ubuntu/+archive/primary/+files/libgcrypt11_1.5.3-2ubuntu4.2_amd64.deb \
 && sudo dpkg -i libgcrypt11_1.5.3-2ubuntu4.2_amd64.deb \
 && rm -f libgcrypt11_1.5.3-2ubuntu4.2_amd64.deb

# Configure the IDEs to use Chromium's source directory as workspace.
ENV WORKSPACE /home/user/chromium/src/

# Update Chromium third_party repos and run pre-compile hooks.
WORKDIR /home/user/chromium/src
RUN gclient runhooks --jobs=`nproc`

# Configure Chromium build.
RUN gn gen out/Default --args="enable_nacl=false is_component_build=true use_jumbo_build=true symbol_level=1"

# Configure Janitor for Chromium
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
