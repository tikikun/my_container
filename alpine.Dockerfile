# Use the latest Alpine image
FROM alpine:latest


COPY ./vim_setup /root/.config/nvim

# Install packages
RUN apk update && apk upgrade \
  && apk add --no-cache \
    clang \
    clang-dev \
    alpine-sdk \
    cmake \
    ccache \
    python3 \
    zsh \
    neovim

# Set clang as the default compiler
RUN ln -sf /usr/bin/clang /usr/bin/cc \
  && ln -sf /usr/bin/clang++ /usr/bin/c++ \
  && cc --version \
  && c++ --version


RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY .zshrc /root/.zshrc

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

RUN git clone https://github.com/z-shell/F-Sy-H.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H

# Set working directory
WORKDIR /code

# Set the entrypoint script
ENTRYPOINT ["zsh"]
