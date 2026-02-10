# <img src="https://raw.githubusercontent.com/SpamTagger/st-exim/refs/heads/main/st-exim.svg" alt="st-exim logo" style="height:2em; vertical-align:middle;"> st-exim

Custom build of Exim4 for SpamTagger using Podman and GitHub Actions

# Usage

The `st-exim` package will be built from the GitHub source tree by checking out a tagged version of the Git repository. This requires the version to be provided as a commandline option, as described below, which matches an existing Git tag.

To build the package, you can use the one-step compose file or build and extract the package manually:

## One-step build

Run the `build_and_extract.sh` script with the target version as an option:

```
./build_and_extract.sh 4.99.1
```

you can optionally provide the distribution codename as the second argument and the architecture (amd64, arm64) as the third, and an alternate export destination directory as the forth. By default, it will use:

```
./build-and-export.sh 4.99.1 trixie amd64 ./dist
```

and the output file will be located at `./dist/st-exim_4.99.1+trixie_amd64.deb`.

# GitHub Actions

A workflow exists to automatically build and upload the .deb packages to GitHub Releases any time that a new version tag (starting with `v`) is pushed. The version number after the `v` will be used as the Exim version to build (ie. The tag `v4.99.1` will build version `4.99.1`). TODO: there is not currently an option to create a patched version of the same release (ie. `4.99.1-1`).

# Developer notes for future releases

SpamTagger specific build options are defined in `DEBIAN/EDITME`. These need to be updated appropriately based on Exim changelogs (for new features, deprecations and renaming of options).

It would be best practice to increment the default version number within `Dockerfile` and this document.
