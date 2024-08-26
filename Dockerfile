# Stage 1: install tools from a common base image
FROM --platform=linux/amd64 debian:12-slim AS build

# Install curl, jq, and bash
RUN apt-get update && \
  apt-get install -y curl jq bash

# Set version
ENV ARGOCD_VERSION=v2.12.2

# copy install script
COPY ./install_argocli.sh /install.sh

# Install argocd CLI
RUN /install.sh

# Stage 2: copy tools from the build stage to a distroless image
FROM --platform=linux/amd64 gcr.io/distroless/base-debian12:nonroot

# Copy the necessary binaries and libraries from the build stage
COPY --from=build /bin/bash /bin/bash
COPY --from=build /bin/ls /bin/ls
COPY --from=build /bin/cat /bin/cat
COPY --from=build /usr/bin/curl /usr/bin/curl
COPY --from=build /usr/bin/env /usr/bin/env
COPY --from=build /usr/bin/jq /usr/bin/jq
COPY --from=build /usr/local/bin/argocd /usr/local/bin/argocd

# If needed, copy necessary shared libraries
COPY --from=build /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=build /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu

# copy terminator script
COPY ./terminator.sh /usr/local/bin/sync-terminator

# Set sync-terminator as the entrypoint
CMD ["sync-terminator"]
