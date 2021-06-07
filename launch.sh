#!/bin/bash

# Usage
#   ./launch.sh

# Example:
#   export CONTENT_DIR="/Users/molomby/Downloads/offlinecontent"
#   export LIBRARY_XML_DIR="/Users/molomby/Downloads"
#   export PORT=8283
#   ./launch.sh

# Exit on error, empty vars error
set -eu
print_status () {
	printf "\n\x1b[32m ➔  \x1b[37m${1}\e[0m\n";
}

# Sort out our vars
KIWIX_TOOLS=/kiwix-tools
CONTENT_DIR="${CONTENT_DIR:-/kiwix-content}"
LIBRARY_XML_DIR="${LIBRARY_XML_DIR:-${HOME}}"
PORT="${PORT:-8282}"

# Debug
print_status "Running with..."
echo "KIWIX_TOOLS=$KIWIX_TOOLS"
echo "CONTENT_DIR=$CONTENT_DIR"
echo "LIBRARY_XML_DIR=$LIBRARY_XML_DIR"
echo "PORT=$PORT"

# List files we'll be serving
print_status "ZIMs available..."
ls -l ${CONTENT_DIR}/*.zim

# Hash the file listing so we know if we need to regenerate the lib xml
FILE_LIST_HASH=$(ls -l ${CONTENT_DIR}/*.zim | sha1sum | cut -f1 -d' ' | tail -c 10)
LIBRARY_XML_PATH="${LIBRARY_XML_DIR}/library-${FILE_LIST_HASH}.xml"

# Create the lib xml or not
if test -f "$LIBRARY_XML_PATH"; then
    print_status "Existing library XML found for current ZIM file list hash (${FILE_LIST_HASH})"
else
    print_status "No library XML found for current ZIM file list hash (${FILE_LIST_HASH}); creating..."

	# Build the library xml file
	${KIWIX_TOOLS}/kiwix-manage ${LIBRARY_XML_PATH} add ${CONTENT_DIR}/*.zim
	print_status "Library XML built at '${LIBRARY_XML_PATH}'"
fi

# Start the server
print_status "Launching server on port $PORT"
exec ${KIWIX_TOOLS}/kiwix-serve --port=$PORT --library "$LIBRARY_XML_PATH"
