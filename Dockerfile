# syntax=docker/dockerfile:1

FROM ubuntu:24.04
# Delete default 'ubuntu' user
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

# Install all required packages
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -yq sudo build-essential \
      chrpath cpio debianutils diffstat file gawk gcc git iputils-ping \
      libacl1 locales python3 python3-git python3-jinja2 python3-pexpect \
      python3-pip python3-subunit socat texinfo unzip wget xz-utils zstd ssh \ 
      curl lz4 && \
    rm -rf /var/lib/apt-lists/*

# Download repo tool from source
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo && chmod a+x /bin/repo

# Update locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG=en_US.utf8

# Create a 'build' user with the same uid and gid as the container owner
ARG UID=1000
ARG GID=1000
RUN groupadd build -g ${GID} && \
    useradd -lms /bin/bash -p build build -u ${UID} -g ${GID} && \
    usermod -aG sudo build && \
    echo "build:build" | chpasswd

USER build
WORKDIR /home/build
RUN git config --global user.email "build@example.com" && git config --global user.name "build"

# Make sure downloads and sstate are cached in dedicated directories
RUN mkdir downloads sstate-cache
ENV BB_ENV_PASSTHROUGH_ADDITIONS="DL_DIR SSTATE_DIR"
ENV DL_DIR="/home/build/downloads"
ENV SSTATE_DIR="/home/build/sstate-cache"

# Copy init script
COPY --chown=${UID}:${GID} scripts/setuprepo.sh .
