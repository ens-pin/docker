# Use the latest Ubuntu LTS version as the base image
FROM node:18

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV VITE_API_URL=http://0.0.0.0:42069

RUN npm install -g pnpm
RUN npm install -g ens-index-ipfs-cli

# Set the working directory
WORKDIR /app
RUN git clone https://github.com/ens-pin/ens-index-ipfs-service.git

WORKDIR /app/ens-index-ipfs-service
RUN pnpm install

WORKDIR /app
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        wget https://dist.ipfs.tech/kubo/v0.34.1/kubo_v0.34.1_linux-amd64.tar.gz; \
    elif [ "$ARCH" = "aarch64" ]; then \
        wget https://dist.ipfs.tech/kubo/v0.34.1/kubo_v0.34.1_linux-arm64.tar.gz; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi
RUN tar -xvzf kubo_v0.34.1_linux-*.tar.gz

WORKDIR /app/kubo*
RUN /app/kubo*/install.sh
RUN ipfs version
RUN ipfs init

# Set environment variables
ENV DATABASE_SCHEMA=my_schema

WORKDIR /app
RUN git clone https://github.com/ens-pin/control-dashboard.git
WORKDIR /app/control-dashboard
RUN pnpm install
#RUN pnpm build
#RUN npm install serve -g

WORKDIR /app/ens-index-ipfs-service
RUN chmod -R a+rx /app

CMD ["sh", "-c", "ipfs daemon & cd /app/ens-index-ipfs-service && pnpm run start & cd /app/control-dashboard && pnpm dev --host 0.0.0.0"]
# Default command
#CMD ["sh", "-c", "ipfs daemon & npm run start"]