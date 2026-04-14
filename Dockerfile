# Use an official Go image with the correct version
FROM golang:1.23-alpine

# Set the working directory inside the container
WORKDIR /app

# Install necessary packages (e.g., Git)
RUN apk add --no-cache git

# Install Fabric using Go
RUN go install github.com/danielmiessler/fabric@latest

# Set environment variables for Go paths
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:/root/.local/bin:/usr/local/bin:$PATH

# Set the default command to run Fabric
CMD ["fabric", "-h"]
