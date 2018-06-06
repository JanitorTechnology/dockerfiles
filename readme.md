# Dockerfiles

[![Circle CI](https://img.shields.io/circleci/project/github/JanitorTechnology/dockerfiles.svg)](https://circleci.com/gh/JanitorTechnology/workflows/dockerfiles)
[![Docker Hub](https://img.shields.io/docker/automated/janitortechnology/janitor.svg)](https://hub.docker.com/r/janitortechnology/)

Popular development environments as Docker containers.

All images are available on Docker Hub under [/janitortechnology/](https://hub.docker.com/u/janitortechnology/) (previously under [/janx/](https://hub.docker.com/u/janx/)).

## Ubuntu-dev

Most images here are based on `ubuntu-dev`, which is basically `ubuntu:16.04` with:

- Useful packages like `clang`, `git`, `vim`…
- A `user` which can `sudo`
- Remote access via `ssh`, [Cloud9 IDE](https://c9.io) and [noVNC](https://kanaka.github.io/noVNC/)
- An extensible `supervisor` configuration

To build [janitortechnology/ubuntu-dev](https://hub.docker.com/r/janitortechnology/ubuntu-dev/) yourself:

    cd ubuntu-dev
    docker build -t janitortechnology/ubuntu-dev -f ubuntu-dev.dockerfile .

## Chromium

    docker run -it --rm janitortechnology/chromium /bin/bash
    user@container:~/chromium/src (master) $ ninja -C out/Release chrome -j18

To build [janitortechnology/chromium](https://hub.docker.com/r/janitortechnology/chromium/) yourself:

    cd chromium
    docker build -t janitortechnology/chromium -f chromium.dockerfile .

## Discourse

    docker run -it --rm janitortechnology/discourse /bin/bash
    user@container:~/discourse (master) $ bundle exec rspec

To build [janitortechnology/discourse](https://hub.docker.com/r/janitortechnology/discourse/) yourself:

    cd discourse
    docker build -t janitortechnology/discourse -f discourse.dockerfile .

## Firefox

    docker run -it --rm janitortechnology/firefox /bin/bash
    user@container:~/firefox (master) $ ./mach build

To build [janitortechnology/firefox](https://hub.docker.com/r/janitortechnology/firefox/) yourself:

    cd firefox
    docker build -t janitortechnology/firefox -f firefox-git.dockerfile .

Or for a Firefox image that uses Mercurial (`hg`) instead of Git:

    cd firefox
    docker build -t janitortechnology/firefox-hg -f firefox-hg.dockerfile .

## Firefox for Android (Fennec)

    docker run -it --rm janitortechnology/fennec /bin/bash
    user@container:~/fennec (master) $ ./mach build

To build [janitortechnology/fennec](https://hub.docker.com/r/janitortechnology/fennec/) yourself:

    cd fennec
    docker build -t janitortechnology/fennec -f fennec.dockerfile .

## Rust

    docker run -it --rm janitortechnology/rust /bin/bash
    user@container:~/rust (master) $ ./x.py build

To build [janitortechnology/rust](https://hub.docker.com/r/janitortechnology/rust/) yourself:

    cd rust
    docker build -t janitortechnology/rust -f rust.dockerfile .

## Servo

    docker run -it --rm janitortechnology/servo /bin/bash
    user@container:~/servo (master) $ ./mach build -d

To build [janitortechnology/servo](https://hub.docker.com/r/janitortechnology/servo/) yourself:

    cd servo
    docker build -t janitortechnology/servo -f servo.dockerfile .

## Thunderbird

    docker run -it --rm janitortechnology/thunderbird /bin/bash
    user@container:~/thunderbird $ ./mozilla/mach build

To build [janitortechnology/thunderbird](https://hub.docker.com/r/janitortechnology/thunderbird/) yourself:

    cd thunderbird
    docker build -t janitortechnology/thunderbird -f thunderbird.dockerfile .

## Janitor

    docker run -it --rm janitortechnology/janitor /bin/bash
    user@container:~/janitor (master) $ node app

To build [janitortechnology/janitor](https://hub.docker.com/r/janitortechnology/janitor/) yourself:

    cd janitor
    docker build -t janitortechnology/janitor -f janitor.dockerfile .

## PrivateBin

    docker run -it --rm janitortechnology/privatebin /bin/bash
    user@container:~/janitor (master) $ unit-test

To build [janitortechnology/privatebin](https://hub.docker.com/r/janitortechnology/privatebin/) yourself:

    cd privatebin
    docker build -t janitortechnology/privatebin -f privatebin.dockerfile .

# More Dockerfiles

There are other great development Dockerfiles out there:

## [KDE](https://github.com/rcatolino/kdesrcbuild-docker)

    docker run -it --rm rcay/kdecore /bin/bash
    user@container:~/kdesrc-build $ ./kdesrc-build --make-options=-j8 --no-src

To build [rcay/kdecore](https://hub.docker.com/r/rcay/kdecore/) yourself:

    cd kde
    docker build -t rcay/kdecore -f kde.docker .
