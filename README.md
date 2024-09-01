# Libwebp Wasm

## Introduction

The process of converting the [libwebp](https://github.com/webmproject/libwebp) project from C/C++ to WASM is achieved using the [Emscripten](https://emscripten.org) compiler. The general workflow is as follows:

![Emscripten Compilation Flow](https://user-images.githubusercontent.com/8049878/189127696-bba0af00-d58d-42b3-b09e-9e15eb255731.png "Emscripten Compilation Flow")

## Usage

### Installation

#### Toolchain

This includes installing [emsdk](https://github.com/emscripten-core/emsdk), [cmake](https://cmake.org), and [pnpm](https://pnpm.io). For specific installation methods, refer to the [Emscripten official documentation](https://emscripten.org/docs/getting_started/downloads.html), [pnpm official documentation](https://pnpm.io/installation), and [installing cmake](https://juejin.cn/post/6844904024433491982#heading-6).

#### submodule

```bash
git submodule update --init --recursive --remote --rebase
```

### Build

Currently, the build script only supports macOS, so the following build method is only applicable to macOS. Additionally, if you are using zsh, it is recommended to install [the dotenv plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv) to enable features like setting environment variables if a .env file is present in the current directory.

```bash
pnpm build:mac
```

Note: The modification of upstream submodule project code is currently done by running the git apply command. Sometimes you need to commit your own changes in the submodule directory and manually generate the patch.

```bash
pnpm build:patch
```

## Example

- [Gif to Webp](https://libwebp-wasm.github.io/gif2webp/example/)

## License

MIT
