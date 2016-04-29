# Dockerfiles

Popular development environments as Docker containers.

All images are available on [Docker Hub](https://hub.docker.com/u/janx/).

## [Ubuntu-dev](https://hub.docker.com/r/janx/ubuntu-dev/)

Most images will soon use `janx/ubuntu-dev`, which is basically `ubuntu:16.04` with:

- Useful packages like `curl`, `git`, `vim`…
- A `user` which can `sudo`
- Remote access via `ssh`, [cloud9](https://c9.io) and [novnc](https://kanaka.github.io/noVNC/)
- An extensible `supervisor` configuration

To build `janx/ubuntu-dev` yourself:

    cd ubuntu-dev
    docker build -t janx/ubuntu-dev -f ubuntu-dev.dockerfile .

## [Chromium](https://hub.docker.com/r/janx/chromium/)

    docker run -ti janx/chromium
    user@container:~/chromium/src$ ninja -C out/Release chrome -j18

To build `janx/chromium` yourself:

    cd chromium
    docker build -t janx/chromium - < chromium.dockerfile

## [Firefox](https://hub.docker.com/r/janx/firefox/)

    docker run -ti janx/firefox
    user@container:~/firefox$ ./mach build

To build `janx/firefox` yourself:

    cd firefox
    docker build -t janx/firefox - < firefox.dockerfile

## [Servo](https://servo.org/)

    docker run -ti janx/servo
    user@container:~/servo$ ./mach build -d

To build `janx/servo` yourself:

    cd servo
    docker build -t janx/servo - < servo.dockerfile

## [Thunderbird](https://hub.docker.com/r/janx/thunderbird/)

    docker run -ti janx/thunderbird
    user@container:~/thunderbird$ ./mozilla/mach build

To build `janx/thunderbird` yourself:

    cd thunderbird
    docker build -t janx/thunderbird - < thunderbird.dockerfile

# More Dockerfiles

There are other great development Dockerfiles out there:

## [KDE](https://github.com/rcatolino/kdesrcbuild-docker)

    docker run -ti janx/kde
    user@container:~/kde ./kdesrc-build --make-options=-j8 --no-src

To build `janx/kde` yourself:

    cd kde
    docker build -t janx/kde - < kde.docker
