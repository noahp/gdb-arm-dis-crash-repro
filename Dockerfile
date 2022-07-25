FROM ubuntu:22.04@sha256:bace9fb0d5923a675c894d5c815da75ffe35e24970166a48a4460a48ae6e0d19

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bison \
    build-essential \
    ca-certificates \
    file \
    flex \
    gdb \
    git \
    libdebuginfod-dev \
    libexpat-dev \
    libgmp-dev \
    liblzma-dev \
    libncurses-dev \
    pv \
    texinfo \
    wget2 \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* \
    && \
    update-ca-certificates

###
# GCC ARM toolchain
###

# grab a particular GCC ARM toolchain
ARG ARM_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2?revision=ca0cbf9c-9de2-491c-ac48-898b5bbc0443&hash=B47BBB3CB50E721BC11083961C4DF5CA
RUN wget2 --force-progress --progress=bar ${ARM_URL} -O /opt/gcc-arm-none-eabi.tar.bz2 && \
    mkdir -p /opt/gcc-arm-none-eabi && \
    pv --force /opt/gcc-arm-none-eabi.tar.bz2 | tar xj --directory /opt/gcc-arm-none-eabi --strip-components 1
ENV PATH=/opt/gcc-arm-none-eabi/bin:${PATH}

###
# GDB
###

# 1. grab gdb sources
ARG GDB_URL=https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.gz
RUN wget2 --force-progress --progress=bar ${GDB_URL} -O /opt/gdb.tar.gz && \
    mkdir -p /opt/gdb && \
    pv --force /opt/gdb.tar.gz | tar xz --directory /opt/gdb --strip-components 1

# 2. build gdb with debug symbols
RUN \
    cd /opt/gdb && \
    export CPPFLAGS="$CPPFLAGS -fcommon -Wno-constant-logical-operand -ggdb" && \
    export CFLAGS="$CFLAGS -Wno-constant-logical-operand -Wno-format-nonliteral -Wno-self-assign -ggdb" && \
    export CXXFLAGS="$CXXFLAGS -ggdb" && \
    ( \
        ./configure \
            --target="arm-elf-linux" \
            --enable-targets=all \
            --with-lzma \
            --with-expat \
            --without-guile \
            --without-libunwind-ia64 \
            --with-zlib \
            --without-babeltrace \
            --disable-ld \
            --disable-gprof \
            --disable-gas \
            --disable-sim \
            --disable-gold \
        && \
        make -j $(nproc) \
    )
    # \
    # && \
    # /opt/gdb/gdb --version

# grab the repro version of the application
ARG DEMO_GIT_URL=https://github.com/noahp/gdb-bug-repro-example.git
ARG DEMO_COMMIT=6bf2757195dd949e0d047c1b146753793711e453
RUN git clone ${DEMO_GIT_URL} /opt/demo && \
    cd /opt/demo && \
    git checkout ${DEMO_COMMIT} && \
    git submodule update --init --recursive

# build the demo app
RUN cd /opt/demo && \
    make
