# Use the latest Alpine image
FROM alpine:latest

# Install packages
RUN apk update && apk upgrade \
  && apk add --no-cache \
    clang \
    clang-dev \
    alpine-sdk \
    cmake \
    ccache \
    python3 \
    zsh

# Set clang as the default compiler
RUN ln -sf /usr/bin/clang /usr/bin/cc \
  && ln -sf /usr/bin/clang++ /usr/bin/c++ \
  && cc --version \
  && c++ --version

# Set working directory
WORKDIR /code

# Set the entrypoint script
ENTRYPOINT ["/bin/zsh"]
