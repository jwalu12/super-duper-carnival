# syntax=docker/dockerfile:1.7

FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG ADS_REF=v1.1.5
ARG ADS_BUILD_JOBS=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        libboost-all-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --depth 1 --branch "${ADS_REF}" https://github.com/adshares/ads.git

RUN cmake \
        -S /src/ads/src \
        -B /src/ads/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_PROJECT_CONFIG=ads \
    && cmake --build /src/ads/build \
        --parallel "${ADS_BUILD_JOBS}" \
        --target ads adsd

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ADS_UID=10001
ARG ADS_GID=10001

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libboost-filesystem1.74.0 \
        libboost-iostreams1.74.0 \
        libboost-program-options1.74.0 \
        libboost-system1.74.0 \
        libboost-thread1.74.0 \
        libssl3 \
        procps \
        python3 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${ADS_GID}" ads \
    && useradd --uid "${ADS_UID}" --gid ads --create-home --shell /bin/bash ads \
    && install -d -m 0700 -o ads -g ads /home/ads/.adsd /home/ads/.ads

COPY --from=builder /src/ads/build/esc/ads /usr/local/bin/ads
COPY --from=builder /src/ads/build/escd/adsd /usr/local/bin/adsd
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chmod=0755 render-cron-entrypoint.sh /usr/local/bin/render-cron-entrypoint.sh
COPY monitor.py rewards_calculator.py render-healthcheck.py /opt/adshares/

RUN chmod 0755 /usr/local/bin/ads /usr/local/bin/adsd \
    && chown -R ads:ads /opt/adshares

ENV HOME=/home/ads \
    ADS_NODE_DIR=/home/ads/.adsd \
    ADS_USER_DIR=/home/ads/.ads

# Render persistent disks are mounted by the platform at runtime. Keeping the
# entrypoint as root lets it initialize that mounted directory even when the
# platform-owned mount rejects chmod/chown from an unprivileged user.
USER root
WORKDIR /home/ads

EXPOSE 8091 9091 10000

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
    CMD python3 -c "import os, socket; port=int(os.environ.get('OFFICE_PORT') or os.environ.get('PORT') or 9091); s=socket.create_connection(('127.0.0.1', port), 3); s.close()"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["adsd"]
