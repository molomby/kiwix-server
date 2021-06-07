# Kiwix Server

A Basic Kiwix content server in Docker using `kiwix-serve`.
Images are published to the [`molomby/kiwix-server` repo](https://hub.docker.com/repository/docker/molomby/kiwix-server/general) on Docker Hub.

⚠️ **This is a toy** ⚠️

You're probably better of using the [offical `kiwix-tools` images](https://github.com/kiwix/kiwix-tools/tree/master/docker) that do the same thing.

## Kiwix

> Kiwix is an offline reader for online content like Wikipedia, Project Gutenberg, or TED Talks.
> – [kiwix.org](https://www.kiwix.org/en/)

We use the [`kiwix-tools`](https://github.com/kiwix/kiwix-tools) for management and serving ZIM files over HTTP, specifically:

* [`kiwix-manage`](https://wiki.kiwix.org/wiki/Kiwix-manage)
* [`kiwix-serve`](https://wiki.kiwix.org/wiki/Kiwix-serve)

### Content

For ZIM files, see..

* [Various sites](https://wiki.kiwix.org/wiki/Content_in_all_languages) in the Kiwix wiki
	- Inc: Wikipedia and other Wiki- sites, TED talks, Stack Exchange sites, Khan Academy, various other sites.
	- Or as a [Google Sheet](https://docs.google.com/spreadsheets/d/1lWXdwy3OIfZ1Ob2cQR707OMHSva3khTcAXZE9MK9ad8/edit#gid=552567720)
* [Project Gutenberg](https://ebookfoundation.org/openzim.html) modules
	- Over 60,000 free eBooks
* [Zimit](https://youzim.it/) online tool that generates ZIM files from arbitary websites

## Environment Vars

The following environment vars are consumed by a launch script (`launch.sh`) that runs the server:

### `CONTENT_DIR`

Where should the image look for ZIM files.
Defaults to `/kiwix-content`.

All `*.zim` files in this directory will be added to the library at startup and served.
If the files in the dir are modified, the container should be restarted.

The container doesn't need write access to this dir (unless it's also used as the `LIBRARY_XML_DIR`).
As such, it's sensible to mount a volume at the specified path with the read-only flag, eg: `--volume /Users/molomby/Downloads/offlinecontent:/kiwix-content:ro`.

### `LIBRARY_XML_DIR`

Where should the image store it's library XML files.
Defaults to `${HOME}` (which resolves to `/root`).

To serve multiple zim files, we use `kiwix-manage` to create a library file with the related meta data.
The file itself is named based on a hash of the file listing of `CONTENT_DIR`.
Anytime ZIM files in the `CONTENT_DIR` are modified (and the container restarted) a new library file will be created.

There's little reason to mount a volume at the path specified here but, if you were to, the container will require write access.

### `PORT`

The container port on which `kiwix-serve` will run.
Defaults to `8282`.

Note this is the internal port.
Regardless of what is configured here you'll need to map it to a port on the host (assuming a bridged network), eg:
`--publish 8282:8282`.

## Build Process

Building in dev and pushing to Docker Hub.

```sh
# Build
docker build --tag kiwix-server:latest .

# Test locally
# docker run --init --publish 8282:8282 --volume /Users/molomby/Downloads/offlinecontent:/kiwix-content:ro --name kiwix-server kiwix-server:latest

# Add publishing tags
docker tag kiwix-server:latest molomby/kiwix-server:latest
docker tag kiwix-server:latest molomby/kiwix-server:2.0.0

# Push to docker hub
docker push --all-tags molomby/kiwix-server
```
