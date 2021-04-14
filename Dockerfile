FROM ubuntu:18.04

# Default end result image and target, can be overwritten with `docker build`
ARG MACHINE="jetson-nano-2gb-devkit"
ARG BRANCH="c4ef10f44d92ac9f1e4725178ab0cefd9add8126"
ARG DISTRO="tegrademo"
ARG BUILD_IMAGE="demo-image-full"
ARG NVIDIA_DEVNET_MIRROR="file:///home/user/sdk_downloads"

# Install build system's dependencies
RUN apt-get update
RUN apt-get -y upgrade

# Remote Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    software-properties-common \
    gawk \
    git \
    wget \
    git-core \
    subversion \
    screen \
    tmux \
    sudo \
    iputils-ping \
    iproute2 \
    tightvncserver \
    apt-transport-https \
    ca-certificates \
    gpg \
    curl \
    lsb-release

# Build Tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    make \
    cmake \
    gcc \
    gcc-multilib \
    g++-multilib \
    gcc-8 \
    g++-8 \
    clang-format \
    clang-tidy \
    cpio \
    diffstat \
    build-essential \
    bmap-tools \
    vim \
    nano \
    bash-completion \
    gnupg

# Development Libraries
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libegl1-mesa \
    libsdl1.2-dev \
    libasio-dev \
    libtinyxml2-dev \
    libcppunit-dev \
    libzstd-dev \
    libbenchmark-dev \
    libspdlog-dev \
    liblog4cxx-dev \
    libcunit1-dev \
    libbz2-dev

# Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    dkms \
    iputils-ping  \
    mesa-utils \
    debianutils \
    pylint3 \
    xterm \
    unzip \
    sysstat \
    texinfo \
    chrpath \
    socat \
    xz-utils  \
    locales \
    fluxbox

# Python Packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python \
    python3 \
    python-rosdep \
    python3-pip \
    python3-pexpect \
    python3-git \
    python3-jinja2 \
    python3-vcstools \
    python3-babeltrace \
    python3-pygraphviz \
    python3-mock \
    python3-nose \
    python3-mypy \
    python3-pytest-mock \
    python3-lttng

# Upgrade Python's package installer
RUN pip3 install -U pip \
    -U colcon-core \
    -U colcon-common-extensions

# Docker Dependencies for nVidia SDK Install
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io

# nVidia SDK
RUN wget https://github.com/CalebProvost/dockter-l4t/raw/master/sdkmanager_1.4.1-7402_amd64.deb
RUN apt-get install -y ./sdkmanager_1.4.1-7402_amd64.deb

# User management
RUN adduser --disabled-password --gecos '' user
RUN adduser user sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set environment
RUN dpkg-reconfigure locales
RUN locale-gen en_US.UTF-8
ENV LANG en_us.UTF-8
ENV LC_ALL en_US.UTF-8
ENV NVIDIA_DEVNET_MIRROR "file:///home/user/sdk_downloads"
RUN update-locale
RUN mkdir -p /home/user/build
COPY ./entrypoint.sh /home/user/build/
USER user
WORKDIR /home/user/build

# ENTRYPOINT [ "/home/user/build/entrypoint.sh" ]
CMD [ "bash", "-c", "/home/user/build/entrypoint.sh" ]
