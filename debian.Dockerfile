FROM python:3.13-slim AS clang19_image

# Install dependencies
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
        gnupg2 wget ca-certificates apt-transport-https \
        autoconf automake cmake dpkg-dev file make patch libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Install clang from Debian repos
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
        clang \
        clangd \
        clang-tidy \
        clang-format \
        lld \
        libc++-dev \
        libc++abi-dev && \
    rm -rf /var/lib/apt/lists/*

FROM clang19_image AS base_image

COPY ./vim_setup /root/.config/nvim

# Install additional packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        zsh \
        git \
        curl \
        ca-certificates \
        gettext \
        unzip \
        procps \
        vim \
        && rm -rf /var/lib/apt/lists/*

# Install latest Node.js via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI via official install script
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install get-shit-done to ~/.claude/
RUN npx get-shit-done-cc --claude --global

# Set clang as the default compiler
RUN update-alternatives --query cc | grep -q "Value: /usr/bin/clang" || \
    (which clang && ln -sf $(which clang) /usr/bin/cc && ln -sf $(which clang++) /usr/bin/c++) && \
    cc --version && c++ --version

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

# Ensure ~/.local/bin is in PATH (where npx global binaries are installed)
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.zshrc

RUN git clone https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/z-shell/F-Sy-H.git \
        ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/F-Sy-H

WORKDIR /code

ENTRYPOINT ["zsh"]