# Doom C++ Project

Hello! I'm programming Doom in C++. That's it. Nothing fancy here.

Based on the amazing tutorial series ["Let's Program Doom" by 3DSage](https://youtu.be/huMO4VQEwPc?list=PLMTDxt7L_MNXx7QP80seZUfcSoJ4jl34D).

## Workflows

GitHub workflows should do all the heavy lifting with building and creating installers.

## Build locally

I highly recommend to use Docker and the included `.devcontainer`.

If you prefer to set up your own local environment, here are the pre-requisites:

- CMake 3.30 or higher
- C++17 compatible compiler (GCC, Clang, or MSVC)
- OpenGL and GLUT (`freeglut3-dev` on Ubuntu)
- For development, `clang` tools (`clang-format clang-tidy clangd` on Ubuntu)

### ... with Dev Container or local environment

Best for development.

Build with CMake:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -G Ninja && cmake --build build
```

Create installers with:

```sh
cmake --build build --target package
```

Run doom-cpp binary:

```sh
./bin/doom-cpp
```

### ... with Docker

This docker image will build and run the program for you.

Build the Docker image:

```sh
docker build -f docker/prod.Dockerfile -t doom-cpp:latest .
```

Run the container:

```sh
docker run --rm doom-cpp:latest
```

## Format and lint: clangd setup

Run once so `clangd` knows which compile flags are being used:

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

Check formatting with:

```sh
find src -name '*.cpp' -o -name '*.h' | xargs clang-format --dry-run --Werror
```

Lint with:

```sh
clang-tidy -p build src/*.cpp -- -std=c++17 -I./src
```

Or just use `vscode-clangd` extension for VS Code, which is included in the dev container.
