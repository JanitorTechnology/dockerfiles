# Dockerfiles

Popular development environments as Docker containers.

All images are available on [Docker Hub](https://hub.docker.com/u/janx/).

## [Ubuntu-dev](https://hub.docker.com/r/janx/ubuntu-dev/)

Most images here are based on `janx/ubuntu-dev`, which is basically `ubuntu:16.04` with:

- Useful packages like `clang`, `git`, `vim`…
- A `user` which can `sudo`
- Remote access via `ssh`, [Cloud9](https://c9.io) and [noVNC](https://kanaka.github.io/noVNC/)
- An extensible `supervisor` configuration

To build `janx/ubuntu-dev` yourself:

    cd ubuntu-dev
    docker build -t janx/ubuntu-dev -f ubuntu-dev.dockerfile .

## [Chromium](https://hub.docker.com/r/janx/chromium/)

    docker run -ti janx/chromium /bin/bash
    user@container:~/chromium/src$ ninja -C out/Release chrome -j18

To build `janx/chromium` yourself:

    cd chromium
    docker build -t janx/chromium -f chromium.dockerfile .

## [Firefox](https://hub.docker.com/r/janx/firefox/)

    docker run -ti janx/firefox /bin/bash
    user@container:~/firefox$ ./mach build

To build `janx/firefox` yourself:

    cd firefox
    docker build -t janx/firefox -f firefox.dockerfile .

## [Servo](https://hub.docker.com/r/janx/servo/)

    docker run -ti janx/servo /bin/bash
    user@container:~/servo$ ./mach build -d

To build `janx/servo` yourself:

    cd servo
    docker build -t janx/servo -f servo.dockerfile .

## [Thunderbird](https://hub.docker.com/r/janx/thunderbird/)

    docker run -ti janx/thunderbird /bin/bash
    user@container:~/thunderbird$ ./mozilla/mach build

To build `janx/thunderbird` yourself:

    cd thunderbird
    docker build -t janx/thunderbird -f thunderbird.dockerfile .

# More Dockerfiles

There are other great development Dockerfiles out there:

## [KDE](https://github.com/rcatolino/kdesrcbuild-docker)

    docker run -ti rcay/kdecore /bin/bash
    user@container:~/kdesrc-build ./kdesrc-build --make-options=-j8 --no-src

To build `rcay/kdecore` yourself:

    cd kde
    docker build -t rcay/kdecore -f kde.docker .
