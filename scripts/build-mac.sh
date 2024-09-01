#!/usr/bin/env bash

echo "Install dependencies using Homebrew"
brew install libpng jpeg giflib

echo "Install dependencies using pnpm"
pnpm install

echo "Initialize and update submodules"
git submodule update --init --recursive --remote --rebase

dists=('es' 'lib' 'dist')

echo "Clean es, lib, src, and dist"
rm -rf src && git stash -qu && git stash drop -q

for dist in "${dists[@]}"
do
  rm -rf "$dist" && mkdir "$dist"
done

cd libjpeg || exit 0

echo "Dynamically update libjpeg"
git apply --quiet --check ../patches/libjpeg.diff

result0=$?
if [ $result0 -eq 0 ]; then
  git apply ../patches/libjpeg.diff
else
  echo "Failed to update libjpeg dynamically"
  exit 1
fi

echo "Build libjpeg"
emcmake cmake -DBUILD_STATIC=ON .
emmake make clean && emmake make

echo "Move libjpeg.a to jpeg/xxx/lib directory"
jpegLibPath="$(brew --cellar jpeg)/$(brew list --versions jpeg | tr ' ' '\n' | tail -1)/lib"
if [ -f "${jpegLibPath}/libjpeg.a.bak" ]; then
  rm -f "${jpegLibPath}/libjpeg.a"
else
  mv "${jpegLibPath}/libjpeg.a" "${jpegLibPath}/libjpeg.a.bak"
fi
mv libjpeg.a "${jpegLibPath}/libjpeg.a"

echo "Clean libjpeg build artifacts"
emmake make clean && git stash -qu && git stash drop -q

cd ../libpng || exit 0

echo "Build libpng"
emcmake cmake -DPNG_SHARED=OFF -DPNG_TESTS=OFF -DZLIB_LIBRARY=~/emsdk/upstream/emscripten/system/lib/libz.a -DZLIB_INCLUDE_DIR=~/emsdk/upstream/emscripten/system/include -DCMAKE_C_FLAGS="-s USE_ZLIB=1" .
emmake make clean && emmake make

echo "Move libpng.a to libpng/xxx/lib directory"
libpngLibPath="$(brew --cellar libpng)/$(brew list --versions libpng | tr ' ' '\n' | tail -1)/lib"
if [ -f "${libpngLibPath}/libpng16.a.bak" ]; then
  rm -f "${libpngLibPath}/libpng16.a"
else
  mv "${libpngLibPath}/libpng16.a" "${libpngLibPath}/libpng16.a.bak"
fi
mv libpng16.a "${libpngLibPath}/libpng16.a"

echo "Clean libpng build artifacts"
emmake make clean && git stash -qu && git stash drop -q

cd ../giflib || exit 0

echo "Dynamically update giflib"
git apply --quiet --check ../patches/giflib.diff

result1=$?
if [ $result1 -eq 0 ]; then
  git apply ../patches/giflib.diff
else
  echo "Failed to update giflib dynamically"
  exit 1
fi

echo "Build giflib"
emmake make clean && emmake make

echo "Move libgif.a to giflib/xxx/lib directory"
# https://stackoverflow.com/a/638980/4441984
# https://apple.stackexchange.com/a/145481/237892
giflib2Path="$(brew --cellar giflib)/$(brew list --versions giflib | tr ' ' '\n' | tail -1)/lib"
if [ -f "${giflib2Path}/libgif.a.bak" ]; then
  rm -f "${giflib2Path}/libgif.a"
else
  mv "${giflib2Path}/libgif.a" "${giflib2Path}/libgif.a.bak"
fi
mv libgif.a "${giflib2Path}/libgif.a"

echo "Clean giflib build artifacts"
# https://unix.stackexchange.com/a/297423/232523
emmake make clean && git stash -qu && git stash drop -q

cd ../libwebp || exit 0

echo "Dynamically update libwebp"
git apply --quiet --check ../patches/libwebp.diff

result2=$?
if [ $result2 -eq 0 ]; then
  git apply ../patches/libwebp.diff
else
  echo "Failed to update libwebp dynamically"
  exit 1
fi

echo "Configure the project using CMake"
cd webp_js || exit 0
emcmake cmake -DEMSCRIPTEN_FORCE_COMPILERS=ON -DCMAKE_BUILD_TYPE=Release -DWEBP_BUILD_WEBP_JS=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_IMG2WEBP=OFF -DWEBP_BUILD_EXTRAS=OFF -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_USE_THREAD=OFF -DZLIB_LIBRARY=~/emsdk/upstream/emscripten/system/lib/libz.a -DZLIB_INCLUDE_DIR=~/emsdk/upstream/emscripten/system/include -DCMAKE_C_FLAGS="-s USE_ZLIB=1" -DGIF_LIBRARY="$(brew --prefix giflib)/lib/libgif.a" -DGIF_INCLUDE_DIR="$(brew --prefix giflib)/include" -DJPEG_LIBRARY="$(brew --prefix jpeg)/lib/libjpeg.a" -DJPEG_INCLUDE_DIR="$(brew --prefix jpeg)/include" -DPNG_LIBRARY="$(brew --prefix libpng)/lib/libpng16.a" -DPNG_PNG_INCLUDE_DIR="$(brew --prefix libpng)/include" ../

echo "Build wasm files"
emmake make

echo "Copy wasm and js files to gif2webp/lib and gif2webp/src"
# https://superuser.com/a/503657/645165
# https://stackoverflow.com/a/2193653/4441984
# https://superuser.com/a/397325/645165
find . -maxdepth 1 \( -type f -name 'gif2webp.js' -not -name '*.worker.js' \) -print0 | xargs -0 -I {} cp -a {} ../../src

for dist in "${dists[@]}"
do
  find . -maxdepth 1 \( -type f -name 'gif2webp.wasm' -o -regex '.*\.worker\.js$' \) -print0 | xargs -0 -I {} cp -a {} "../../$dist"
done

echo "Clean libwebp/webp_js"
cd ..
rm -rf webp_js && git stash -qu && git stash drop -q
