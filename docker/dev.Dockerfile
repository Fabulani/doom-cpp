FROM gcc:13

RUN apt-get update && apt-get install -y \
    ninja-build \
    gdb \
    git \
    wget \
    curl \
    zip \
    unzip \
    tar \
    pkg-config \
    sudo \
    freeglut3-dev \
    clang-format clang-tidy clangd \
    && rm -rf /var/lib/apt/lists/*

# Install CMake 3.30.5
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-linux-x86_64.sh -O /tmp/cmake-install.sh && \
    chmod +x /tmp/cmake-install.sh && \
    /tmp/cmake-install.sh --skip-license --prefix=/usr/local && \
    rm /tmp/cmake-install.sh

WORKDIR /workspace
