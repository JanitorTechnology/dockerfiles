# Dockerfiles

Popular development environments as Docker containers.

Full images available on [Docker Hub](https://hub.docker.com/u/janx/).

## Usage Example

    sudo docker build -t janx/firefox - < firefox.docker
    sudo docker run -ti janx/firefox /bin/bash
    user@container:~/firefox$ ls

## Supported Projects

- Firefox ([janx/firefox](https://registry.hub.docker.com/u/janx/firefox/))
- Chromium ([janx/chromium](https://registry.hub.docker.com/u/janx/chromium/))
