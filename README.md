# mc-exim

Compile MailCleaner's build of Exim with Docker/Podman/etc.

# Usage

The `mc-exim` package will be built from the GitHub source tree by checking out a tagged version of the Git repository. This requires the version to be provided as a commandline option, as described below, which matches an existing Git tag.

To build the package, you can use the one-step compose file or build and extract the package manually:

## One-step build

Run the `build_and_extract.sh` script with the target version as an option:

```
./build_and_extract.sh 4.97
```

you can optionally provide a destination directory as the second argument to have the `.deb` exported to a specific directory. By default, `${HOME}/debs/` will be used.

If successful, the path to the new `.deb` will be printed.

## Run manually

Note: `docker` will be used below, but note that other equivalent runtimes, such as `podman` which are compatible with the `Dockerfile`/`Containerfile` format can be substituted.

Below, the following option will be used:

* `${EXIM_VERSION}` - The target tag version to be checked out from Git, which will also be used as the output file name. (default: `4.97`)

Build compilation container:

```
docker build --build-arg EXIM_VERSION=${EXIM_VERSION} -t build/mc-exim -f Containerfile
```

Run the container to get build results:

```
docker run -d build/mc-exim
```

the last line of the output will provide a hash ID which should be used as the CONTAINER_ID below.

Copy the `.deb` out of the container:

```
docker cp CONTAINER_ID:/mc-exim-${EXIM_VERSION}_amd64.deb /path/to/copy/to/
```

Clean up the container:

```
docker rm CONTAINER_ID
```

# Notes for future releases

MailCleaner specific build options are defined in `DEBIAN/EDITME`. These need to be updated appropriately based on Exim changelogs (for new features, deprecations and renaming of options).

It would be best practice to increment the default version number within `Containerfile` and this document.
