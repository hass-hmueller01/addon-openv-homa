# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/home-assistant/${BUILD_ARCH}-base-debian:bookworm
FROM $BUILD_FROM

ENV VCONTROLD_VERSION="v0.98.12"
ENV LOG_TIMESTAMP="%Y-%m-%d %T"

# Execute during the build of the image
ARG TEMPIO_VERSION=2021.09.0 BUILD_ARCH
RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

RUN echo "alias l='ls --color=auto -alF'" >> /root/.bashrc

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential git cmake telnet libxml2-dev mosquitto-clients yq xmlstarlet vim-tiny && \
    mkdir -p /usr/local/src && \
    rm -rf /usr/local/src/* && \
    git -C /usr/local/src clone --depth 1 --branch $VCONTROLD_VERSION https://github.com/openv/vcontrold.git && \
    cd /usr/local/src/vcontrold && \
    mkdir build && \
    cd build && \
    cmake -DMANPAGES=OFF .. && \
    make install && \
    make clean && \
    git -C /usr/local/src clone -b main https://github.com/hass-hmueller01/hass-addon-helper.git && \
    cd /usr/local/src/hass-addon-helper && \
    make install && \
    cd && \
    apt-get purge -y --auto-remove build-essential git cmake && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/src/*

# Copy root filesystem
COPY rootfs /

ENTRYPOINT ["/init"]
