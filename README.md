# mc-exim

Compilation script for MailCleaner's build of Exim.

`install_exim.sh`, when provided with a version number as an argument, will install all dependencies, fetch the Exim source repository, checkout the desired version tag, then build a .deb.

# TODO

Create a Dockerfile to automatically set up the build environment, export the .deb, and stage the new package.
