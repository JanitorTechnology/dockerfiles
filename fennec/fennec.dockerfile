FROM janx/ubuntu-dev

# Install the latest Android Studio.
# Package source: https://developer.android.com/studio/index.html#downloads
RUN mkdir /tmp/android-studio \
 && cd /tmp/android-studio \
 && wget -O android-studio.zip https://dl.google.com/dl/android/studio/ide-zips/3.0.1.0/android-studio-ide-171.4443003-linux.zip \
 && unzip -q android-studio.zip \
 && mv android-studio /home/user \
 && rm -rf /tmp/android-studio

# Install Fennec build dependencies.
RUN sudo apt-get update -q \
 && sudo apt-get upgrade -qy \
 && sudo apt-get install -qy default-jdk \
 && wget -O /tmp/bootstrap.py https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py \
 && python /tmp/bootstrap.py --no-interactive --application-choice=mobile_android \
 && rm -f /tmp/bootstrap.py \
 && rustup target add armv7-linux-androideabi
 
# Download Fennec's source code.
RUN hg clone --uncompressed https://hg.mozilla.org/mozilla-unified/ fennec \
 && cd fennec \
 && hg update central
WORKDIR fennec

# Configure Fennec build.
ADD mozconfig /home/user/fennec/
RUN sudo chown user:user /home/user/fennec/mozconfig

# Set up additional Fennec build dependencies.
RUN mkdir -p /home/user/.mozbuild \
 && ./mach mercurial-setup -u \
 && ./mach artifact toolchain --from-build proguard-jar \
 && mv proguard /home/user/.mozbuild/

# Configure Cloud9 to use Fennec's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/fennec/" /etc/supervisord.conf

# Configure Janitor for Fennec.
ADD janitor.json /home/user/janitor.json
RUN sudo chown user:user /home/user/janitor.json

# Build Fennec APK.
RUN ./mach build \
 && ./mach package

# Configure Android Studio for Fennec.
RUN ./mach gradle clean app:assembleLocalWithGeckoBinariesMinApi21PhotonDebug
