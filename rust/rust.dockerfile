FROM janitortechnology/ubuntu-dev

# No additional dependencies are required.

# Download Rust's source code.
RUN git clone https://github.com/rust-lang/rust /home/user/rust
WORKDIR /home/user/rust
RUN git checkout 56714acc5eb0687ed9a7566fdebe5528657fc5b3

# Configure the IDEs to use Rust's source directory as workspace.
ENV WORKSPACE /home/user/rust/

# Add build configuration preset
COPY config.toml /home/user/rust/

# Build Rust.
RUN ./x.py build

# Configure Janitor for Rust
COPY janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
