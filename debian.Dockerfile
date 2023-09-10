FROM debian:bookworm-slim AS clang16_image

# Install dependencies
RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
        gnupg2 wget ca-certificates apt-transport-https \
        autoconf automake cmake dpkg-dev file make patch libc6-dev

# Install LLVM
RUN echo "deb https://apt.llvm.org/bookworm llvm-toolchain-bookworm-16 main" \
        > /etc/apt/sources.list.d/llvm.list && \
    wget -qO /etc/apt/trusted.gpg.d/llvm.asc \
        https://apt.llvm.org/llvm-snapshot.gpg.key && \
    apt-get -qq update && \
    apt-get install -qqy -t llvm-toolchain-bookworm-16 clang-16 clangd-16 clang-tidy-16 clang-format-16 lld-16 libc++-16-dev libc++abi-16-dev && \
    for f in /usr/lib/llvm-16/bin/*; do ln -sf "$f" /usr/bin; done && \
    rm -rf /var/lib/apt/lists/*

FROM clang16_image AS base_image

COPY ./vim_setup /root/.config/nvim

# Install packages
RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3 \
    zsh \
    git \
    curl \
    ca-certificates \
    gettext \
    unzip \
  && rm -rf /var/lib/apt/lists/*

# Set clang as the default compiler
RUN ln -sf /usr/bin/clang /usr/bin/cc \
  && ln -sf /usr/bin/clang++ /usr/bin/c++ \
  && cc --version \
  && c++ --version

FROM base_image AS install_neovim

WORKDIR /code

RUN git clone https://github.com/neovim/neovim
WORKDIR /code/neovim
RUN git checkout v0.9.1
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
RUN make install
WORKDIR /code
RUN rm -rf neovim

FROM install_neovim as install_cli

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY dotfiles/.zshrc /root/.zshrc

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

RUN git clone https://github.com/z-shell/F-Sy-H.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H

# Set working directory
WORKDIR /code

# Set the entrypoint script
ENTRYPOINT ["zsh"]
