# This Dockerfile creates a small image with bash and the latest version of the Argocd CLI
FROM --platform=linux/amd64 alpine:3.14

# Install bash and curl
RUN apk add --no-cache bash curl jq

# Set version
ENV ARGOCD_VERSION=v2.12.2

# copy install script
COPY ./install_argocli.sh /install.sh

# Install argocd CLI
RUN /install.sh

# copy terminator script
COPY ./terminator.sh /usr/local/bin/sync-terminator
