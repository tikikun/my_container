FROM nvcr.io/nvidia/isaac-sim:4.2.0 as base_image

# Install dependencies
RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
        gnupg2 wget ca-certificates apt-transport-https \
        autoconf automake cmake dpkg-dev file make patch libc6-dev
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
    python3.11 \
    #python3-pip \
    python3.11-dev \
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
    nodejs \
    npm \
  && rm -rf /var/lib/apt/lists/*

# Set clang as the default compiler
#RUN ln -sf /usr/bin/clang /usr/bin/cc \
#  && ln -sf /usr/bin/clang++ /usr/bin/c++ \
#  && cc --version \
#  && c++ --version

# Update the alternatives for Python 3.12
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 100

# Fix cuda clang issue
# Command to append content to the clangd config file
RUN mkdir -p /root/.config/clangd && \
    echo "CompileFlags:" >> /root/.config/clangd/config.yaml && \
    echo "  Add:" >> /root/.config/clangd/config.yaml && \
    echo "    - --cuda-gpu-arch=sm_86" >> /root/.config/clangd/config.yaml && \
    echo "  Remove:" >> /root/.config/clangd/config.yaml && \
    echo "    - --generate-code=arch=*" >> /root/.config/clangd/config.yaml && \
    echo "    - -forward-unknown-to-host-compiler" >> /root/.config/clangd/config.yaml

FROM base_image AS install_neovim

WORKDIR /code

RUN git clone https://github.com/neovim/neovim
WORKDIR /code/neovim
RUN git checkout v0.9.5
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

# Set up zsh to work properly
# RUN chsh -s /bin/zsh root && echo "cd /code" >> /root/.zshrc

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

RUN apt update && \
    apt install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /code

RUN git clone https://github.com/neovim/neovim
WORKDIR /code/neovim
RUN git checkout v0.9.5
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
RUN make install
WORKDIR /code
RUN rm -rf neovim
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

ENTRYPOINT ["/isaac-sim/runheadless.native.sh", "-v"]
