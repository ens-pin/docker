# Use the latest Ubuntu LTS version as the base image
FROM node:18

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /app
RUN git clone https://github.com/ens-pin/ens-index-ipfs-service.git
RUN npm install -g ens-index-ipfs-cli

WORKDIR /app/ens-index-ipfs-service
RUN npm install

RUN wget https://dist.ipfs.tech/kubo/v0.34.1/kubo_v0.34.1_linux-amd64.tar.gz -o kubo.tar.gz
RUN tar -xvzf kubo_v0.34.1_linux-amd64.tar.gz
RUN cd kubo; ./install.sh
RUN ipfs version
RUN nohup ipfs daemon &>/dev/null &

# Set environment variables
ENV DATABASE_SCHEMA=my_schema

# Default command
CMD ["npm", "run", "start"]