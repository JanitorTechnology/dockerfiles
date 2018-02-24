FROM janx/ubuntu-dev

# No additional dependencies are required.

# Download Rust's source code.
RUN git clone https://github.com/rust-lang/rust /home/user/rust
WORKDIR /home/user/rust

# Configure Cloud9 to use Rust's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/rust/" /etc/supervisord.conf

# Add build configuration preset
COPY config.toml /home/user/rust/

# Build Rust.
RUN ./x.py build

# Configure Janitor for Rust
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
