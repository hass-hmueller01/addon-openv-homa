# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/home-assistant/${BUILD_ARCH}-base-debian:bookworm
FROM $BUILD_FROM

ENV VCONTROLD_VERSION="v0.98.12"

# Execute during the build of the image
ARG TEMPIO_VERSION=2021.09.0 BUILD_ARCH
RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential git cmake telnet libxml2-dev mosquitto-clients yq xmlstarlet vim-tiny && \
    git clone --depth 1 --branch $VCONTROLD_VERSION https://github.com/openv/vcontrold.git && \
    cd vcontrold && \
    mkdir build && \
    cd build && \
    cmake -DMANPAGES=OFF .. && \
    make install && \
    make clean && \
    cd ../.. && \
    apt-get purge -y --auto-remove build-essential git cmake && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* vcontrold

# Copy root filesystem
COPY rootfs /
COPY bashrc /root/.bashrc

ENTRYPOINT ["/init"]
