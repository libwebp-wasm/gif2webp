#!/usr/bin/env bash

dists=('es' 'lib' 'dist')

cd giflib || exit 0

echo "Dynamically update giflib"
git apply --check ../patches/giflib.diff

result0=$?
if [ $result0 -eq 0 ]; then
  git apply ../patches/giflib.diff
else
  echo "Failed to update giflib dynamically"
  exit 1
fi

echo "Build giflib"
emmake make clean && emmake make

cd ../libwebp || exit 0

echo "Dynamically update libwebp"
git apply --check ../patches/libwebp.diff

result1=$?
if [ $result1 -eq 0 ]; then
  git apply ../patches/libwebp.diff
else
  echo "Failed to update libwebp dynamically"
  exit 1
fi

echo "Configure the project using CMake"
cd webp_js || exit 0
emcmake cmake -DEMSCRIPTEN_FORCE_COMPILERS=ON -DCMAKE_BUILD_TYPE=Release -DWEBP_BUILD_WEBP_JS=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_IMG2WEBP=OFF -DWEBP_BUILD_EXTRAS=OFF -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_USE_THREAD=OFF -DGIF_LIBRARY="/gif2webp/giflib/libgif.a" -DGIF_INCLUDE_DIR=/usr/local/include ../

echo "Build wasm files"
emmake make

echo "Copy js files gif2webp/src"
# https://superuser.com/a/503657/645165
# https://stackoverflow.com/a/2193653/4441984
# https://superuser.com/a/397325/645165
find . -maxdepth 1 \( -type f -name 'gif2webp.js' -not -name '*.worker.js' \) -print0 | xargs -0 -I {} cp -a {} ../../src

cd ../../
pnpm fetch --frozen-lockfile && pnpm install --frozen-lockfile && pnpm build:rollup

cd libwebp/webp_js || exit 0

echo "Copy wasm files to gif2webp/lib, gif2webp/dist and gif2webp/es"
for dist in "${dists[@]}"
do
  find . -maxdepth 1 \( -type f -name 'gif2webp.wasm' -o -regex '.*\.worker\.js$' \) -print0 | xargs -0 -I {} cp -a {} "../../$dist"
done

echo "Clean libwebp/webp_js"
cd ../
rm -rf webp_js && git stash -qu && git stash drop -q
