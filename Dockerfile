# Builder image
FROM gcr.io/nebula-tasks/crawl-build as builder

# Runtime image
FROM ubuntu:20.04

# Environment Variables
ENV APP_DEPS="bzip2 liblua5.1-0-dev python3-minimal python3-pip python3-yaml \
    python-is-python3 ncurses-term locales-all sqlite3 libpcre3 locales \
    lsof sudo libbot-basicbot-perl" \
  DATA_DIR=/data \
  DEBIAN_FRONTEND=noninteractive

# Install packages for the runtime
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y musl-dev && \
  ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1 && \
  apt-get install -y ${APP_DEPS} \
    --option=Dpkg::Options::=--force-confdef

# Install Tornado
RUN pip3 install tornado

# Copy over the compiled files
COPY --from=builder /app/ /app/

# Copy over custom configs
COPY settings/init.txt /app/settings/
COPY util/webtiles-init-player.sh /app/util/
COPY webserver/config.py /app/webserver/
COPY webserver/games.d/* /app/webserver/games.d/

# Copy over the entrypoint
COPY scripts/entrypoint-webtiles.sh /app/entrypoint.sh

# Clean up unnecessary package lists
RUN rm -rf /var/lib/apt/lists/*

# Expose ports
EXPOSE 8080

# Set the WORKDIR
WORKDIR /app

# Launch WebTiles server
ENTRYPOINT [ "./entrypoint.sh" ]
