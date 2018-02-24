FROM janitortechnology/rust

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy && rustup update

# Update and rebuild Rust's source code.
RUN cd /home/user/rust \
 && git pull --rebase origin master \
 && ./x.py build
