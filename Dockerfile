
# Build stage
# ----------------------------
FROM alpine:3.18 as build

# Everything here is temp
WORKDIR /tmp/kiwix-tools

# Download and extract the kiwix tools
RUN wget -O kiwix-tools.tar.gz https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz \
    && tar -xf kiwix-tools.tar.gz --strip-components=1

# Run stage
# ----------------------------
FROM alpine:3.18

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
COPY --from=build /tmp/kiwix-tools/kiwix-manage /tmp/kiwix-tools/kiwix-serve .

# Add the launch script
COPY ./launch.sh /kiwix-tools/launch.sh

# Start app
CMD ["./launch.sh"]
