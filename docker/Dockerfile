FROM emscripten/emsdk

LABEL maintainer="liuliang@w3ctech.com"

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN apt update && apt upgrade -y \
    && apt update && apt install -y --no-install-recommends \
    wget \
    tar \
    ca-certificates \
    xmlto \
    imagemagick \
    build-essential
RUN wget https://nchc.dl.sourceforge.net/project/giflib/giflib-5.2.2.tar.gz -O giflib-5.2.2.tar.gz && \
tar -xvf giflib-5.2.2.tar.gz && cd giflib-5.2.2 && make && make install
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.4/cmake-3.30.4-linux-x86_64.tar.gz && \
tar -zxvf cmake-3.30.4-linux-x86_64.tar.gz --strip-components=1 -C /usr/local && rm cmake-3.30.4-linux-x86_64.tar.gz

RUN corepack enable && corepack install --global pnpm@10.4.1
WORKDIR /gif2webp

COPY . ./
RUN chmod +x ./docker/build.sh && apt clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash", "./docker/build.sh"]
