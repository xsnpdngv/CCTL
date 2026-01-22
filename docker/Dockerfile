# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/root/.local/bin:$PATH

RUN set -e; \
    PACKAGES="\
        ca-certificates \
        curl \
        wget \
        git \
        make \
        cmake \
        ninja-build \
        gcc \
        g++ \
        gdb \
        clang \
        clang-tools \
        clang-tidy \
        llvm \
        cppcheck \
        ccache \
        openjdk-17-jre \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        pipx \
        libncurses-dev \
        uuid-dev \
        liblua5.3-dev \
        libsctp-dev \
        libssl-dev \
        libxml2-dev \
        nghttp2 \
        libnghttp2-dev \
        libcunit1 \
        libcunit1-dev \
        locales \
    "; \
    apt-get update && \
    apt-get install --dry-run $PACKAGES && \
    apt-get install -y $PACKAGES && \
    rm -rf /var/lib/apt/lists/*


RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=en_US.UTF-8


# ---- CodeChecker ----
RUN pipx install codechecker \
 && CodeChecker version


WORKDIR /work
