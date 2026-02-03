FROM nvidia/cuda:13.0.2-cudnn-devel-ubuntu22.04 AS clang18_image

# Install dependencies
RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
        gnupg2 wget ca-certificates apt-transport-https \
        autoconf automake cmake dpkg-dev file make patch libc6-dev

# Install LLVM 18
RUN echo "deb https://apt.llvm.org/jammy llvm-toolchain-jammy-18 main" \
        > /etc/apt/sources.list.d/llvm.list && \
    wget -qO /etc/apt/trusted.gpg.d/llvm.asc \
        https://apt.llvm.org/llvm-snapshot.gpg.key && \
    apt-get update && \
    apt-get install -y -t llvm-toolchain-jammy-18 clang-18 clangd-18 clang-tidy-18 clang-format-18 lld-18 libc++-18-dev libc++abi-18-dev && \
    for f in /usr/lib/llvm-18/bin/*; do ln -sf "$f" /usr/bin; done && \
    rm -rf /var/lib/apt/lists/*

FROM clang18_image AS base_image

COPY ./vim_setup /root/.config/nvim

# Add python PPA
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y software-properties-common \
  && add-apt-repository ppa:deadsnakes/ppa -y

# Install packages
RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3.13 \
    python3.13-dev \
    zsh \
    nvtop \
    btop \
    tmux \
    git \
    curl \
    ca-certificates \
    gettext \
    unzip \
    fd-find \
    procps \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI via official install script
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install get-shit-done to ~/.claude/
RUN npx get-shit-done-cc --claude --global

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /root/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install 22

# Set clang as the default compiler
RUN which clang && ln -sf $(which clang) /usr/bin/cc && ln -sf $(which clang++) /usr/bin/c++ && \
    cc --version && c++ --version

# Update the alternatives for Python 3.13
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.13 100

# Fix cuda clang issue
# Command to append content to the clangd config file
RUN mkdir -p /root/.config/clangd && \
    echo "CompileFlags:" >> /root/.config/clangd/config.yaml && \
    echo "  Add:" >> /root/.config/clangd/config.yaml && \
    echo "    - --cuda-gpu-arch=sm_86" >> /root/.config/clangd/config.yaml && \
    echo "  Remove:" >> /root/.config/clangd/config.yaml && \
    echo "    - --generate-code=arch=*" >> /root/.config/clangd/config.yaml && \
    echo "    - -forward-unknown-to-host-compiler" >> /root/.config/clangd/config.yaml

# Set the default shell to zsh for SSH sessions
RUN echo "export SHELL=/bin/zsh" >> /root/.bashrc

# Install SSH server and setup
RUN apt-get update && apt-get install -y openssh-server \
  && echo 'root:helloworld' | chpasswd \
  && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && mkdir /var/run/sshd


FROM base_image AS install_neovim

WORKDIR /code

RUN git clone https://github.com/neovim/neovim --depth 1 --branch v0.11.5 && \
    cd neovim && \
    git submodule update --init --recursive && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make install && \
    cd .. && \
    rm -rf neovim

FROM install_neovim AS install_cli

ENV ZSH=/root/.oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    rm -rf /root/.cache

COPY dotfiles/.zshrc /root/.zshrc

# Copy private config from my_private subrepo (API keys, etc.)
COPY my_private/zshrc /tmp/private_zshrc
RUN cat /tmp/private_zshrc >> /root/.zshrc

# Ensure ~/.local/bin is in PATH (where Claude Code and npx global binaries are installed)
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.zshrc

RUN git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/z-shell/F-Sy-H.git \
        ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/F-Sy-H

# Set working directory
WORKDIR /code

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.13

# Install jupyter lab
RUN python -m pip install jupyterhub \
  && npm install -g configurable-http-proxy \
  && python -m pip install jupyterlab notebook ipywidgets

COPY create-user.sh /start-scripts/
COPY jupyterhub_config.py /code/


RUN apt update && \
    apt install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# Start SSH and zsh shell
ENTRYPOINT service ssh restart && /bin/zsh