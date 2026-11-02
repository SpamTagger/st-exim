# <img src="https://raw.githubusercontent.com/SpamTagger/st-exim/refs/heads/main/st-exim.svg" alt="st-exim logo" style="height:2em; vertical-align:middle;"> st-exim

## Usage

This project provides custom versions of Exim4 for SpamTagger. Ordinary SpamTagger users will have no need to interact with this project. Official releases of the `st-exim` package will be provided automatically for the official SpamTagger VM images using the `bootc` update mechanism. The remaining information on this page is relevant to developers and those who wish to modify the Exim build in an unsupported environment.

The `st-exim` package is built from the official Exim source tree by checking out a tagged version of the Git repository. This requires the version to be provided as a commandline option, as described below, which matches an existing Git tag.

The official release of the `st-exim` package is built using GitHub Actions any time that a new tagged version is created matching `v*`. The number following `v` will be used as the target version to check out and build. Once built for each supported OS and architecture version the GitHub Action will create a signed SHA256SUM file to verify the legitimacy and integrity of the packages and then create a new GitHub release. Finally, this will trigger the [`debs`](https://github.com/SpamTagger/debs) to fetch the packages and update the repository at `debs.spamtagger.org`. The latest available package in this repository will be built in to SpamTagger-Bootc images.

### One-step build

To build the package on your own, you can execute the build script which will build the package using `podman`:

```
./build_and_extract.sh 4.100.1
```

`4.100.1` represents the Exim version you would like to build, as provided by the `v4.100.1` tag from the [official repository](https://code.exim.org/exim/exim). You can optionally provide the distribution codename as the second argument and the architecture (amd64, arm64) as the third, and an alternate export destination directory as the forth. By default, it will use:

```
./build-and-export.sh 4.100.1 trixie-updates amd64 ./dist
```

and the output file will be located at `./dist/st-exim_4.100.1+trixie-updates_amd64.deb`.

### Manual build

The `Containerfile` serves as documentation for the step-by-step building of the package.

## Developer notes

The build options which make the SpamTagger release different from upstream are all defined in `DEBIAN/EDITME`. These need to be updated appropriately based on Exim changelogs (for new features, deprecations and renaming of options), or to add and remove functionality as is desired.

It is best practice to increment the default version number within `Dockerfile` and this document with each release, however, this is not strictly necessary so long as we correctly tag the new version.

## GitHub Actions

The package is built automatically and uploaded as a release upon tagging a release. We support 3 release versions which should each be built from their own branch:

* `current` branch - builds for the `trixie-updates` suite and is built into the `current` SpamTagger-Bootc image. These should be rolling releases which are tested and published as quickly as possible after an upstream release.
* `testing` branch - builds for the `forky` suite and is built into the `testing` SpamTagger-Bootc image. These should be rolling releases which are tested and published as soon as is reasonable after the `currunt` release to help ease the transition upon `forky` becoming stable.
* `stable` branch - builds for the `trixie` suite and is built into the `stable` SpamTagger-Bootc image. These should be frozen upon each Debian release becoming stable and only receive security updates throughout the life of that release.

The [`debs`](/SpamTagger/debs) repository gets triggered to rebuild the APT repository every time that a new package is built. It is also responsible for adding the Debian package version (ie. the `-1` in `4.100.1-1`). It will compare all of the most recently discovered packages to any which exist in previous snapshots which have the same version number and will increment the package version until if finds a version with the same modification date, or to the next available version if the package is entirely new. This is a hack around only being able to have one release for each Git Tag. It allows us to delete the release and tag, then push a new tag for the same version to rebuild and get a new package version. The old package version remains in the APT repo but will no longer be available in Releases.
