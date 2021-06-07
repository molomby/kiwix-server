
# Build stage
# ----------------------------
FROM alpine:3.13.5 as build

# We need some tools
RUN apk update && apk add curl

# Everything here is temp
WORKDIR /tmp

# Download and extract the kiwix tools
RUN curl -L -o kiwix-tools.tar.gz http://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64-3.1.2-4.tar.gz
RUN tar -xf kiwix-tools.tar.gz


# Run stage
# ----------------------------
FROM alpine:3.13.5

# We need..
# bash – to run the launch script; could use shell but bash is easier
# perl – it includes sha1sum which we use in launch.sh
# coreutils – it includes cut which we use in launch.sh
RUN apk update && apk add bash perl coreutils

# Default the port
ENV PORT 8282

# Where we put the tools
WORKDIR /kiwix-tools

# Copy the tools we need across from the build image
COPY --from=build /tmp/kiwix-tools_linux-x86_64-3.1.2-4/kiwix-manage /tmp/kiwix-tools_linux-x86_64-3.1.2-4/kiwix-serve /kiwix-tools

# Add the launch script
COPY ./launch.sh /kiwix-tools/launch.sh

# Start app
CMD ["./launch.sh"]
