# syntax=docker/dockerfile:1

FROM ubuntu:24.04
# Delete default 'ubuntu' user
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu

# Install all required packages
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install --no-install-recommends -yq \
    build-essential=12.10ubuntu1 \
    chrpath=0.16-2build1 \
    cpio=2.15+dfsg-1ubuntu2 \
    curl=8.5.0-2ubuntu10.6 \
    debianutils=5.17build1 \
    diffstat=1.66-1build1 \
    file=1:5.45-3build1 \
    gawk=1:5.2.1-2build3 \
    gcc=4:13.2.0-7ubuntu1 \
    git=1:2.43.0-1ubuntu7.3 \
    iputils-ping=3:20240117-1ubuntu0.1 \
    libacl1=2.3.2-1build1.1 \
    locales=2.39-0ubuntu8.6 \
    lz4=1.9.4-1build1.1 \
    python3=3.12.3-0ubuntu2.1 \
    python3-git=3.1.37-3 \
    python3-jinja2=3.1.2-1ubuntu1.3 \
    python3-pexpect=4.9-2 \
    python3-pip=24.0+dfsg-1ubuntu1.3 \
    python3-subunit=1.4.2-3build1 \
    python3-yaml=6.0.1-2build2 \
    socat=1.8.0.0-4build3 \
    ssh=1:9.6p1-3ubuntu13.14 \
    sudo=1.9.15p5-3ubuntu5.24.04.1 \
    texinfo=7.1-3build2 \
    unzip=6.0-28ubuntu4.1 \
    wget=1.21.4-1ubuntu4.1 \
    xz-utils=5.6.1+really5.4.5-1ubuntu0.2 \
    zstd=1.5.5+dfsg2-2build1.1 \
    && rm -rf /var/lib/apt-lists/*

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
ENV BB_ENV_PASSTHROUGH_ADDITIONS="DL_DIR SSTATE_DIR"
ENV DL_DIR="/home/build/downloads"
ENV SSTATE_DIR="/home/build/sstate-cache"

# Define an entrypoint
COPY --chown=${UID}:${GID} ./docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "bash" ]
