#!/usr/bin/env bash

echo "Install dependencies using Homebrew"
brew install giflib

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

cd giflib || exit 0

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
emcmake cmake -DEMSCRIPTEN_FORCE_COMPILERS=ON -DCMAKE_BUILD_TYPE=Release -DWEBP_BUILD_WEBP_JS=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_IMG2WEBP=OFF -DWEBP_BUILD_EXTRAS=OFF -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_USE_THREAD=OFF -DCMAKE_C_FLAGS="-s USE_LIBPNG=1 -s USE_LIBJPEG=1" -DGIF_LIBRARY="$(brew --prefix giflib)/lib/libgif.a" -DGIF_INCLUDE_DIR="$(brew --prefix giflib)/include" ../

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
