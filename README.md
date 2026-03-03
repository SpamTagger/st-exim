# <img src="https://raw.githubusercontent.com/SpamTagger/st-exim/refs/heads/main/st-exim.svg" alt="st-exim logo" style="height:2em; vertical-align:middle;"> st-exim

## Usage

This project provides custom versions of Exim4 for SpamTagger. Ordinary SpamTagger users will have no need to interact with this project. Official releases of the `st-exim` package will be provided automatically for the official SpamTagger VM images using the `bootc` update mechanism. The remaining information on this page is relevant to developers and those who wish to modify the Exim build in an unsupported environment.

The `st-exim` package is built from the official Exim source tree by checking out a tagged version of the Git repository. This requires the version to be provided as a commandline option, as described below, which matches an existing Git tag.

The official release of the `st-exim` package is built using GitHub Actions any time that a new tagged version is created matching `v*`. The number following `v` will be used as the target version to check out and build. Once built for each supported OS and architecture version the GitHub Action will create a signed SHA256SUM file to verify the legitimacy and integrity of the packages and then create a new GitHub release. Finally, this will trigger the [`debs`](https://github.com/SpamTagger/debs) to fetch the packages and update the repository at `debs.spamtagger.org`. The latest available package in this repository will be built in to SpamTagger-Bootc images.

### One-step build

To build the package on your own, you can execute the build script which will build the package using `podman`:

```
./build_and_extract.sh 4.99.1
```

`4.99.1` represents the Exim version you would like to build, as provided by the `v4.99.1` tag from the [official repository](https://code.exim.org/exim/exim). You can optionally provide the distribution codename as the second argument and the architecture (amd64, arm64) as the third, and an alternate export destination directory as the forth. By default, it will use:

```
./build-and-export.sh 4.99.1 trixie amd64 ./dist
```

and the output file will be located at `./dist/st-exim_4.99.1+trixie_amd64.deb`.

### Manual build

The `Containerfile` serves as documentation for the step-by-step building of the package.

## Developer notes

The build options which make the SpamTagger release different from upstream are all defined in `DEBIAN/EDITME`. These need to be updated appropriately based on Exim changelogs (for new features, deprecations and renaming of options), or to add and remove functionality as is desired.

It is best practice to increment the default version number within `Dockerfile` and this document with each release, however, this is not strictly necessary so long as we correctly tag the new version.

TODO: There is not currently a supported option to create a patched version of the same release (ie. `4.99.1-1`). An accomadation for this would need to be made within the `build-and-extract.sh` script to appropriately strip the `-1` suffix when pulling the Exim tag, but leave it on when building the package. Since we generally rely on upstream to fix bugs, it is much more likely that we would just release `4.99.2` if/when it becomes available rather than to create a patched version ourselves. Also, since we distribute updates via SpamTagger-Bootc, and the `debs` repo will correctly serve the latest release files when new VM images are being built, this is of little relevance. The consequence is that users will still install a patched version, but it will simply have the same named version as the un-patched version.

