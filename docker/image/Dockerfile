# Use the latest Alpine base image
FROM alpine:latest

# Install dependencies and update certificates
RUN apk update && \
    apk add --no-cache \
    curl ca-certificates \
    nodejs \
    npm \
    git && \
    update-ca-certificates

# Download and install k6
RUN curl -sSLO https://github.com/grafana/k6/releases/download/v0.54.0/k6-v0.54.0-linux-amd64.tar.gz && \
    tar -xzf k6-v0.54.0-linux-amd64.tar.gz && \
    mv k6-v0.54.0-linux-amd64/k6 /usr/local/bin/ && \
    rm -rf k6-v0.54.0-linux-amd64.tar.gz k6-v0.54.0-linux-amd64

# Set the working directory
WORKDIR /app

# Default command
CMD ["sh"]