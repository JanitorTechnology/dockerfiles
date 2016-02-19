# Dockerfiles

Popular development environments as Docker containers.

All images are available on [Docker Hub](https://hub.docker.com/u/janx/).

## Firefox

    sudo docker run -ti janx/firefox
    user@container:~/firefox$ ./mach build && ./mach run

To build [janx/firefox](https://hub.docker.com/r/janx/firefox/) yourself:

    sudo docker build -t janx/firefox - < firefox.docker

## Chromium

    sudo docker run -ti janx/chromium
    user@container:~/src$ ninja -C out/Release chrome -j18 && out/Release/chrome

To build [janx/chromium](https://hub.docker.com/r/janx/chromium/) yourself:

    sudo docker build -t janx/chromium - < chromium.docker

## Thunderbird

    sudo docker run -ti kewisch/thunderbird
    user@container:~/thunderbird$ ./mozilla/mach build && ./mozilla/mach run

To build *kewisch/thunderbird* yourself:

    sudo docker build -t kewisch/thunderbird - < thunderbird.docker
