# Dockerfiles

Popular development environments as Docker containers.

All images are available on [Docker Hub](https://hub.docker.com/u/janx/).

## Firefox

    sudo docker run -ti janx/firefox
    user@container:~/firefox$ ./mach build && ./mach run

To build [janx/firefox](https://registyrc.hub.docker.com/u/janx/firefox/) yourself:

    sudo docker build -t janx/firefox - < firefox.docker

## Chromium

    sudo docker run -ti janx/chromium
    user@container:~/src$ ninja -C out/Release chrome -j18 && out/Release/chrome

To build [janx/chromium](https://registry.hub.docker.com/u/janx/chromium/) yourself:

    sudo docker build -t janx/chromium - < chromium.docker
