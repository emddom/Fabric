# Use the fully qualified path for Podman compatibility
# Fabric v1.4.445 requires Go 1.25.1+
FROM docker.io/library/golang:1.25.1-alpine

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
# git: for fabric
# python3 & ffmpeg: required for yt-dlp to process YouTube data
# curl: to download the latest yt-dlp binary
RUN apk add --no-cache \
    git \
    python3 \
    ffmpeg \
    curl

# Install the latest yt-dlp binary directly
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp

# Install Fabric using Go
RUN go install github.com/danielmiessler/fabric@latest

# Set environment variables for Go paths
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:/root/.local/bin:/usr/local/bin:$PATH

# Set the default command to run Fabric
CMD ["fabric", "-h"]
