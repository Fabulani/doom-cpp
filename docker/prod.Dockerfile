FROM gcc:13 AS builder

RUN apt-get update && apt-get install -y \
    make \
    ninja-build \
    wget \
    freeglut3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# Install CMake 3.30.5
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-linux-x86_64.sh -O /tmp/cmake-install.sh && \
    chmod +x /tmp/cmake-install.sh && \
    /tmp/cmake-install.sh --skip-license --prefix=/usr/local && \
    rm /tmp/cmake-install.sh

WORKDIR /app
COPY . .

RUN mkdir -p build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build .

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    freeglut3 \
    libgl1 \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/build/bin/* /app/

CMD ["./doom-cpp"]
